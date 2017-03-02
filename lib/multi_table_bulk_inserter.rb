require 'bulk_inserter'

class MultiTableBulkInserter
  def initialize(**options)
    @upserters = Hash.new
    @options   = options
  end

  def add_class(model, **options)
    @upserters[model] = (@options[:batch_size] ? BatchedBulkInserter : BulkInserter).new(model, @options.merge(options))
  end

  def run!
    blocks = [->(_) { yield self }]
    @upserters.values.each_with_index do |upserter, index|
      blocks << ->(_) { upserter.run!(&blocks[index]) }
    end
    blocks.last.call(nil)
  end

  def add(model, record_or_fields)
    model = model.kind_of?(Class) ? model : model.to_s.constantize
    upserter = @upserters.keys.detect { |u| model == u || model.ancestors.include?(u) } or
        raise ArgumentError, "MultiTableBulkInserter not configured for #{model}"
    @upserters[upserter] << record_or_fields
  end
end
