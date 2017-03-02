require 'tempfile'
require 'securerandom'

class BulkInserter
  # @private
  attr_accessor :file
  attr_accessor :strategy

  def self.upsert!(*args, **kwargs)
    instance = new(*args, **kwargs)
    instance.run! { yield instance }
  end

  # @private
  def initialize(model, merge_keys: [], exclude: [], strategy: nil)
    @model   = model.kind_of?(Class) ? model : model.to_s.constantize
    @columns = model.columns.reject { |c| exclude.include? c.name.to_sym }

    @merge_keys = merge_keys
    @other_keys = @columns.map { |c| c.name.to_sym } - merge_keys

    self.strategy = Strategy.for_name(strategy || default_strategy).new(self)
  end

  # @private
  def run!
    Rails.application.operation_logger.tagged(strategy.class.to_s) do
      strategy.run! { yield self }
    end
  end

  def add(record_or_fields)
    strategy.add make_row(record_or_fields)
  end

  alias << add

  private

  def make_row(record_or_fields)
    case record_or_fields
      when @model
        @columns.map { |c| record_or_fields.send(c.name) }
      when Hash
        @columns.map { |c| record_or_fields[c.name.to_sym] }
      when Array
        raise "Insufficient data: Must specify value for every column" unless record_or_fields.size == @columns.size

        record_or_fields
      else
        raise ArgumentError, "Can't import #{record_or_fields.class}"
    end
  end

  def default_strategy
    if Rails.env.test?
      :upsert
    elsif OneMikeAlpha::Configuration.psql[:path] && File.exist?(OneMikeAlpha::Configuration.psql.path)
      @merge_keys.any? ? :fdw : :copy
    else
      :upsert
    end
  end

  # @private
  module Strategy
    # @private
    class Base
      class_attribute :name
      self.name = nil

      attr_reader :base
      attr_reader :records_inserted

      def initialize(base)
        @base = base
      end

      def add(row)
        _add(row)
        @records_inserted += 1
      end

      def run!
        @records_inserted = 0
        _run! { yield }
      end

      protected

      def _add(_row)
        raise NotImplementedError
      end

      def _run!
        start!
        yield
        finish! if @records_inserted.positive?
      end

      def start!() end

      def finish!() end

      %i[merge_keys columns other_keys model].each do |ivar|
        define_method(ivar) { base.instance_variable_get(:"@#{ivar}") }
      end

      private

      def add_column_names!(sql, destination: false)
        columns.each_with_index do |column, index|
          if destination && column.sql_type == 'geography(PointZ,4326)'
            sql << 'ST_GeomFromEWKT(' << model.connection.quote_column_name(column.name) << ')'
          else
            sql << model.connection.quote_column_name(column.name)
          end
          sql << ', ' unless index == columns.size - 1
        end
      end

      def add_values!(sql, row)
        row.each_with_index do |value, index|
          sql << model.connection.quote(value)
          sql << ', ' unless index == row.size - 1
        end
      end

      def add_merge_keys!(sql)
        merge_keys.each_with_index do |column, index|
          sql << model.connection.quote_column_name(column.to_s)
          sql << ', ' unless index == merge_keys.size - 1
        end
      end

      def add_conflict_clause!(sql)
        other_columns.each_with_index do |column, index|
          quoted = model.connection.quote_column_name(column.name)
          sql << quoted << ' = COALESCE(EXCLUDED.' << quoted << ', ' <<
            model.quoted_table_name << '.' << quoted << ')'
          sql << ', ' unless index == other_columns.size - 1
        end
      end

      def other_columns
        @other_columns ||= columns.reject { |c| merge_keys.include?(c.name.to_sym) }
      end
    end

    # @private
    class ActiveRecord < Base
      self.name = :activerecord

      def _add(row)
        merge_attributes = merge_keys.each_with_object({}) do |key, hsh|
          hsh[key] = row[columns.find_index { |c| c.name.to_sym == key }]
        end
        other_attributes = other_keys.each_with_object({}) do |key, hsh|
          hsh[key] = row[columns.find_index { |c| c.name.to_sym == key }]
        end
        if merge_attributes.empty?
          model.create! other_attributes
        else
          model.where(merge_attributes).create_or_update! other_attributes
        end
      end
    end

    class Upsert < Base
      self.name = :upsert

      def _add(row)
        sql = +'INSERT INTO '
        sql << model.quoted_table_name

        sql << ' ('
        add_column_names!(sql)

        sql << ') VALUES ('
        add_values!(sql, row)

        sql << ') ON CONFLICT ('
        add_merge_keys! sql
        sql << ') DO UPDATE SET '
        add_conflict_clause! sql

        model.connection.execute sql
      end
    end

    class MultiUpsert < Base
      self.name = :multi_upsert

      def _add(row)
        @sql << ', ' if records_inserted.positive?
        @sql << '('
        add_values! @sql, row
        @sql << ')'
      end

      protected

      def start!
        @sql = +'INSERT INTO '
        @sql << model.quoted_table_name
        @sql << ' ('
        add_column_names!(@sql)
        @sql << ') VALUES '
      end

      def finish!
        @sql << ' ON CONFLICT ('
        add_merge_keys! @sql
        @sql << ') DO UPDATE SET '
        add_conflict_clause! @sql

        Rails.application.operation_logger.info "Inserting batch"
        model.connection.execute @sql
        @sql = nil
      end
    end

    # @private
    class FileBased < Base
      def _add(row)
        values = row.map do |value|
          case value
            when nil then
              "\\N"
            when String then
              escape(value)
            when Time then
              value.strftime('%Y-%m-%d %H:%M:%S.%L')
            else
              value.to_s
          end
        end
        @file.puts values.join("\t")
      end

      protected

      def _run!
        Tempfile.create do |file|
          @file = file
          start!
          yield
          finish!
        end
      end

      def sudo(query)
        Rails.application.operation_logger.system OneMikeAlpha::Configuration.psql.path, '-c', query, model.connection_config[:database]
      end

      private

      def escape(string)
        new_string = String.new(string)
        begin
          string = String.new(new_string)
          new_string.gsub! '\\', '\\\\'
          new_string.gsub! "\b", "\\b"
          new_string.gsub! "\f", "\\f"
          new_string.gsub! "\n", "\\n"
          new_string.gsub! "\r", "\\r"
          new_string.gsub! "\t", "\\t"
          new_string.gsub! "\v", "\\v"
        end until new_string == string
        return new_string
      end
    end

    # @private
    class FDW < FileBased
      self.name = :fdw

      attr_accessor(:encoding) { Encoding.default_external }

      protected

      def finish!
        table_name        = "batch_import_#{SecureRandom.uuid}"
        quoted_table_name = model.connection.quote_table_name(table_name)

        sql = 'CREATE FOREIGN TABLE '
        sql << quoted_table_name
        sql << ' ('
        add_fdw_columns! sql
        sql << ") SERVER file_import OPTIONS (filename '"
        sql << @file.path.gsub("'", "\\'")
        sql << "', encoding '" << client_encoding << "')"
        sudo sql
        sudo "ALTER TABLE #{quoted_table_name} OWNER TO #{model.connection_config[:username].inspect}"

        sql = 'INSERT INTO '
        sql << model.quoted_table_name
        sql << '('
        add_column_names! sql
        sql << ') SELECT '
        add_column_names! sql, destination: true
        sql << ' FROM '
        sql << quoted_table_name
        sql << ' ON CONFLICT ('
        add_merge_keys! sql
        sql << ') DO UPDATE SET '
        add_conflict_clause! sql

        Rails.application.operation_logger.info "Inserting batch"
        model.connection.execute sql
      ensure
        sudo("DROP FOREIGN TABLE IF EXISTS #{quoted_table_name}") if quoted_table_name
      end

      private

      def client_encoding
        case encoding.to_s
          when 'Big5' then
            'BIG5'
          when 'EUC-JIS-2004' then
            'EUC-JIS_2004'
          when 'EUC-JP' then
            'EUC_JP'
          when 'EUC-KR' then
            'EUC_KR'
          when 'EUC-TW' then
            'EUC_TW'
          when 'GB18030' then
            'GB18030'
          when 'GBK' then
            'GBK'
          when 'ISO-8859-5' then
            'ISO_8859_5'
          when 'ISO-8859-6' then
            'ISO_8859_6'
          when 'ISO-8859-7' then
            'ISO_8859_7'
          when 'ISO-8859-8' then
            'ISO_8859_8'
          when 'KOI8-R' then
            'KOI8R'
          when 'KOI8-U' then
            'KOI8U'
          when 'ISO-8859-1' then
            'LATIN1'
          when 'ISO-8859-2' then
            'LATIN2'
          when 'ISO-8859-3' then
            'LATIN3'
          when 'ISO-8859-4' then
            'LATIN4'
          when 'ISO-8859-9' then
            'LATIN5'
          when 'ISO-8859-10' then
            'LATIN6'
          when 'ISO-8859-13' then
            'LATIN7'
          when 'ISO-8859-14' then
            'LATIN8'
          when 'ISO-8859-15' then
            'LATIN9'
          when 'ISO-8859-16' then
            'LATIN10'
          when 'Emacs-Mule' then
            'MULE_INTERNAL'
          when 'Shift_JIS' then
            'SJIS'
          when 'UTF-8' then
            'UTF8'
          when 'IBM866' then
            'WIN866'
          when 'Windows-874' then
            'WIN874'
          when 'Windows-1250' then
            'WIN1250'
          when 'Windows-1251' then
            'WIN1251'
          when 'Windows-1252' then
            'WIN1252'
          when 'Windows-1253' then
            'WIN1253'
          when 'Windows-1254' then
            'WIN1254'
          when 'Windows-1255' then
            'WIN1255'
          when 'Windows-1256' then
            'WIN1256'
          when 'Windows-1257' then
            'WIN1257'
          when 'Windows-1258' then
            'WIN1258'
          else
            'SQL_ASCII'
        end
      end

      def add_fdw_columns!(sql)
        columns.each_with_index do |col, i|
          sql << model.connection.quote_column_name(col.name) << ' '
          sql << if col.sql_type == 'geography(PointZ,4326)'
                   'VARCHAR(255)'
                 else
                   col.sql_type
                 end
          sql << ', ' unless i == columns.size - 1
        end
      end
    end

    # @private
    class Copy < FileBased
      self.name = :copy

      protected

      def finish!
        sql = 'COPY '
        sql << model.quoted_table_name
        sql << '('
        add_column_names! sql
        sql << ') FROM '
        sql << model.connection.quote(@file.path)

        sudo sql
      end
    end

    def self.for_name(name)
      Base.descendants.detect { |s| s.name && s.name == name }
    end
  end
end

class BatchedBulkInserter < BulkInserter
  def self.upsert!(*args, **kwargs)
    instance = new(*args, **kwargs)
    instance.run! { yield instance }
  end

  # @private
  def initialize(*args, batch_size: 1000, **options)
    super(*args, **options)
    @batch_size        = batch_size
    @duplicate_offsets = merge_keys.map { |key| @columns.find_index { |c| c.name.to_sym == key.to_sym } }
  end

  # @private
  def run!
    @batch = Hash.new
    yield self
    flush!
    @batch = nil
  end

  # @see BulkInserter#add
  def add(record_or_fields)
    row = make_row(record_or_fields)

    keys = @duplicate_offsets.map { |index| row[index] }
    if (existing_row = @batch[keys])
      row.each_with_index { |value, i| existing_row[i] = value if value }
    else
      @batch[keys] = row
    end

    flush! if @batch_size && @batch.size >= @batch_size
  end

  private

  def flush!
    return if @batch.empty?

    strategy.run! do
      @batch.each_value { |row| strategy.add row }
    end
    @batch.clear
  end
end
