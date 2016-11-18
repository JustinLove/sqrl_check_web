require 'sidekiq'
require 'sqrl/check/server'
require 'sqrl/check/web/serialize_reporter'
require 'sqrl/check/web/result_store'
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
          ResultStore.save(id, ser)
        end
      end
    end
  end
end
