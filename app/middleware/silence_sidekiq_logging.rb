class SilenceSidekiqLogging
  def call(_worker, _job, _queue)
    ActiveRecord::Base.logger.silence { yield }
  end
end
