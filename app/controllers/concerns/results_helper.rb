module ResultsHelper
  DEFAULT_PAGE_SIZE = 50

  def paginate(scope, param_prefix: nil, per_page: DEFAULT_PAGE_SIZE, count_scope: scope)
    param = param_prefix ? "#{param_prefix}_page" : 'page'
    page  = params[param].to_i
    page  = 1 if page < 1

    if param_prefix.nil?
      count = count_scope.count
      count = count.size if count.kind_of?(Hash)
      pages = (count/per_page.to_f).ceil

      response.headers['X-Page']     = page.to_s
      response.headers['X-Pages']    = pages.to_s
      response.headers['X-Per-Page'] = per_page.to_s

      @page     = page
      @pages    = pages
      @per_page = per_page
    end

    scope.offset((page-1)*per_page).limit(per_page)
  end

  def sort(param_prefix=nil)
    column_param = param_prefix ? "#{param_prefix}_sort" : 'sort'
    dir_param    = param_prefix ? "#{param_prefix}_dir" : 'dir'

    collector = SortCollector.new
    yield collector

    collector.sort! params[column_param], params[dir_param]
  end

  class SortCollector
    DIRECTIONS = %i[asc desc].freeze
    private_constant :DIRECTIONS

    attr_reader :columns

    def initialize
      @columns                    = Hash.new
      @default_directions         = Hash.new
      @default_directions.default = :asc
      @default_sort               = nil
      @invalid_sort_block         = nil
    end

    def method_missing(meth, *args, &block)
      column = meth.to_s
      @columns[column] = block

      case args.size
        when 0
          # nothing
        when 1
          if args.first.kind_of?(Hash)
            options = args.first
            options.assert_valid_keys :default, :default_dir
            @default_directions[column] = options[:default_dir] if options.include?(:default_dir)
            @default_sort               = column if options[:default]
          else
            raise ArgumentError, "Hash expected, got #{args.first.inspect}"
          end
        else
          raise ArgumentError, "expected 0 arguments, got #{args.size}"
      end
    end

    def respond_to_missing?(_symbol, _include_all) true end

    def invalid_sort!(&block)
      @invalid_sort_block = block
    end

    def sort!(column, dir=nil)
      raise "Must supply at least one sort column" if @columns.empty?

      column = normalize_column(column) || @default_sort
      dir    = normalize_direction(dir) || @default_directions[column]

      if valid_sort?(column, dir)
        return @columns[column].call(dir)
      elsif @invalid_sort_block
        return @invalid_sort_block.call(column, dir)
      else
        return sort!(@default_sort || @columns.keys.first)
      end
    end

    private

    def valid_sort?(column, dir)
      @columns.include?(column) && DIRECTIONS.include?(dir)
    end

    def normalize_column(column)
      case column
        when String
          column.downcase
        when Symbol
          column.to_s
        when nil, false
          nil
        else
          raise ArgumentError, "String or Symbol expected, got #{column.inspect}"
      end
    end

    def normalize_direction(dir)
      case dir
        when Symbol
          DIRECTIONS.detect { |d| d == dir }
        when String
          DIRECTIONS.detect { |d| d.to_s == dir.downcase }
        when nil, false
          nil
        else
          raise ArgumentError, "String or Symbol expected, got #{dir.inspect}"
      end
    end
  end
  private_constant :SortCollector
end
