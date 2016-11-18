require 'sidekiq'

module SQRL
  module Check
    module Web
      module ResultStore
        extend self

        def save(id, result)
          text = JSON.generate(result)
          Sidekiq.redis do |r| r.setex("result:#{id}", 60*60, text) end
        end

        def load(id)
          job = Sidekiq.redis { |r| r.get("result:#{id}") }
          JSON.parse(job) if job
        end

        def exists?(id)
          Sidekiq.redis { |r| r.exists("result:#{id}") }
        end
      end
    end
  end
end
