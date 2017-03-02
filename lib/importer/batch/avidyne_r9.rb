require 'importer/batch/base'
require 'bulk_inserter'

module Importer
  module Batch
    class AvidyneR9 < Base
      def self.can_import?(upload)
        available? && avidyne_r9_set?(upload)
      end

      def import!
        Rails.application.operation_logger.tagged(self.class.to_s) do
          Dir.mktmpdir do |dir|
            Dir.chdir(dir) do
              csv_paths = Array.new
              upload.each_file_importer do |file_importer|
                file_importer.download do |tmpfile|
                  csv_dir = ::File.join(dir, file_importer.file.id.to_s)
                  FileUtils.mkdir csv_dir
                  csv_path = ::File.join(csv_dir, file_importer.filename.to_s)
                  FileUtils.cp tmpfile, csv_path
                  csv_paths << csv_path
                end
              end

              Rails.application.operation_logger.info "Running data loader"
              Rails.application.operation_logger.system self.class.bin_path.to_s, upload.aircraft_id.to_s, *csv_paths

              Dir.glob(::File.join(dir, '*.tsv')).each do |tsv_file|
                next if ::File.empty?(tsv_file)

                table = ::File.basename(tsv_file, '.tsv')
                model = ApplicationRecord.subclasses.detect { |klass| klass.table_name == table } or raise "Model not found for table '#{table}'"

                importer          = BulkInserter::Strategy::FDW.new(nil)
                importer.encoding = Encoding.find('ISO-8859-1')
                importer.define_singleton_method(:merge_keys) { model.primary_key }
                importer.define_singleton_method(:model) { model }
                importer.define_singleton_method(:columns) { model.columns }
                importer.define_singleton_method(:other_keys) { model.columns.map { |c| c.name.to_sym } - importer.merge_keys }
                ::File.open(tsv_file, 'r:ISO-8859-1') do |tsv_fd|
                  importer.instance_variable_set :@file, tsv_fd
                  importer.send :finish!
                end
              end
            end
          end
        end
      end

      def self.available?
        bin_path.exist? && ::File.exist?(OneMikeAlpha::Configuration.psql.path)
      end

      def self.avidyne_r9_set?(batch)
        batch.files_blobs.pluck(:filename).all? { |f| Importer::File::AvidyneR9.can_import?(f) }
      end

      def self.bin_path
        @bin_path ||= Rails.root.join('vendor', 'bin', 'AvidyneR9DataLoader')
      end

      private_class_method :avidyne_r9_set?
    end
  end
end
