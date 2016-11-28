require 'sqrl/check/web/test_worker'
require 'autoscaler/sidekiq'
require 'autoscaler/heroku_platform_scaler'
require 'sidekiq'

Sidekiq.configure_client do |config|
  config.redis = { :size => 1 }
  config.client_middleware do |chain|
    chain.add Autoscaler::Sidekiq::Client, 'default' => Autoscaler::HerokuPlatformScaler.new
  end
end

Sidekiq.configure_server do |config|
  config.redis = { :size => 8 }
  config.server_middleware do |chain|
    chain.add(Autoscaler::Sidekiq::Server, Autoscaler::HerokuPlatformScaler.new, 60) # 60 second timeout
  end
end
