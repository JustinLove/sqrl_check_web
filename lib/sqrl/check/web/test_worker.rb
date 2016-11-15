require 'sidekiq'
require 'sqrl/check/server'
require 'sqrl/check/web/serialize_reporter'
require 'json'

module SQRL
  module Check
    module Web
      class TestWorker
        include Sidekiq::Worker

        def perform(id, options)
          options[:target_url] = options['target_url']
          options[:signed_cert] = options['signed_cert']
          results = Check::Server.run(options)
          ser = SerializeReporter.new(results).to_h
          ser['target_url'] = options['target_url']
          text = JSON.generate(ser)
          Sidekiq.redis do |r| r.setex("result:#{id}", 60*60, text) end
        end
      end
    end
  end
end
