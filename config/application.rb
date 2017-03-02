require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module OneMikeAlpha
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 6.0

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.

    # Use a real queuing backend for Active Job (and separate queues per environment)
    config.active_job.queue_adapter     = :sidekiq
    config.active_job.queue_name_prefix = "1ma_#{Rails.env}"

    # Don't generate system test files.
    config.generators.system_tests      = nil

    config.generators do |g|
      g.template_engine :slim
      g.test_framework :rspec, fixture: true, views: false
      g.integration_tool :rspec
      g.fixture_replacement :factory_bot, dir: 'spec/factories'
    end

    config.active_record.schema_format = :sql

    config.autoload_paths << Rails.root.join('app', 'workflows')

    config.session_store :disabled

    StateMachines::Machine.ignore_method_conflicts = true

    def operation_logger
      @operation_logger ||= begin
                              require 'operation_logger'
                              OperationLogger.new(log: Rails.logger)
                            end
    end
  end
end

Rails.autoloaders.main.ignore Rails.root.join('app', 'frontend')
