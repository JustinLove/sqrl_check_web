require 'sqrl/check/web/test_worker'
require 'sidekiq'

Sidekiq.configure_client do |config|
  config.redis = { }
end

Sidekiq.configure_server do |config|
  config.redis = { }
end
