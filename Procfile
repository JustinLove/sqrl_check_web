web: bundle exec rackup -p $PORT
worker: bundle exec sidekiq -c 6 -r ./lib/sqrl/check/web/sidekiq_config.rb
