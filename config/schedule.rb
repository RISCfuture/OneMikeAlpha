set :output, 'log/cron.log'

every :week do
  rake 'db:seed'
end
