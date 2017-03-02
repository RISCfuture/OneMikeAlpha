class SilenceSidekiqLogging
  def call(_worker, _job, _queue, &block)
    ActiveRecord::Base.logger.silence(&block)
  end
end
