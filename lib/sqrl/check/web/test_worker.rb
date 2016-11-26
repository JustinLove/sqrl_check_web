require 'sidekiq'
require 'sqrl/check/server'
require 'sqrl/check/server/web_client'
require 'sqrl/check/web/serialize_reporter'
require 'sqrl/check/web/result_store'
require 'json'

module SQRL
  module Check
    module Web
      class TestWorker
        include Sidekiq::Worker

        Whitelist = [
          'https://sqrl-test.herokuapp.com/',
        ]

        def perform(id, options)
          options[:target_url] = options['target_url']
          options[:signed_cert] = options['signed_cert']

          unless Whitelist.include?(options['target_url'])
            client = Server::WebClient.new(options)
            exists = client.fetch(options['allowed_url'])

            if exists.status < 200 || exists.status >= 300
              ser = SerializeReporter.precondition_failed('not authorized to test server', "#{options['allowed_url']} returned status #{exists.status}")
              ser['target_url'] = options['target_url']
              ResultStore.save(id, ser)
              return
            end
          end

          results = Check::Server.run(options)
          ser = SerializeReporter.new(results).to_h
          ser['target_url'] = options['target_url']
          ResultStore.save(id, ser)
        rescue => e
          ser = SerializeReporter.exception(e)
          ser['target_url'] = options['target_url']
          ResultStore.save(id, ser)
        end
      end
    end
  end
end
