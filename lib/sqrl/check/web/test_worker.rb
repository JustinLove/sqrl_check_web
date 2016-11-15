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
          results = Check::Server.run(options)
          ser = JSON.generate(SerializeReporter.new(results).to_h)
          Sidekiq.redis do |r| r.setex("result:#{id}", 60*60, ser) end
        end
      end
    end
  end
end
