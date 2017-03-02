source 'https://rubygems.org'

# FRAMEWORK
gem 'bootsnap'
gem 'configoro'
gem 'rails', '6.0.2.2'

# MODELS
gem 'bcrypt'
gem 'composite_primary_keys'
gem 'find_or_create_on_scopes'
gem 'friendly_id'
gem 'image_processing'
gem 'pg'
gem 'state_machines-activerecord'

# GEO
gem 'rgeo'
gem 'rgeo-shapefile', require: 'rgeo/shapefile'
gem 'zipruby'

# CONTROLLERS
gem 'responders'

# VIEWS
# HTML
gem 'slim-rails'
# JS
gem 'webpacker'
# JSON
gem 'jbuilder'
# XML
gem 'builder'

# API
gem 'addressable'
gem 'octokit'
gem 'openssl'
gem 'smarter_csv'

# JOBS
gem 'rgl', github: 'monora/rgl', require: nil
gem 'sidekiq', '< 6'

# IMPORTING
gem 'ruby-units'

# AUTHORIZATION
gem 'devise'
gem 'devise-jwt'

# OTHER
gem 'countries'
gem 'elif'
gem 'whenever'

group :development do
  gem 'listen'
  gem 'puma'

  # DEVELOPMENT
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'faraday-detailed_logger', require: 'faraday/detailed_logger'

  # DEPLOYMENT
  gem 'capistrano'
  gem 'capistrano-bundler'
  gem 'capistrano-passenger'
  gem 'capistrano-rails'
  gem 'capistrano-rvm'
  gem 'capistrano-sidekiq'
end

group :doc do
  gem 'redcarpet'
  gem 'yard', require: nil
end

group :test do
  # SPECS
  gem 'rails-controller-testing'
  gem 'rspec-rails', '4.0.0.beta.3'

  # ISOLATION
  gem 'database_cleaner'
  gem 'fakefs', require: 'fakefs/safe'
  gem 'timecop'
  gem 'webmock'

  # FACTORIES
  gem 'factory_bot_rails'
  gem 'ffaker'
end

group :production do
  # CACHE
  gem 'redis'

  # CONSOLE
  gem 'irb'
end
