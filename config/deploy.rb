# config valid only for current version of Capistrano
lock '~> 3'

set :application, 'one_mike_alpha'
set :repo_url, 'https://github.com/RISCfuture/OneMikeAlpha'

# Default deploy_to directory is /var/www/my_app_name
set :deploy_to, '/var/www/one_mike_alpha'

set :rvm_ruby_version, '2.7.1@1ma'

append :linked_files, 'config/master.key', 'config/sidekiq.yml'

append :linked_dirs, 'log', 'tmp/pids', 'tmp/cache', 'tmp/sockets',
       'public/system'

set :sidekiq_config, 'config/sidekiq.yml'
