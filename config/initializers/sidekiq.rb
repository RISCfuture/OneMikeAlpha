require 'sidekiq'
require 'silence_sidekiq_logging'

Sidekiq.configure_server do |config|
  config.server_middleware do |chain|
    chain.add SilenceSidekiqLogging
  end
end
