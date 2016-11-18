module SQRL
  module Check
    module Web
      module PendingSessionStore
        extend self

        def sending(server_string, props)
          return unless props
          text = JSON.generate(props)
          Sidekiq.redis do |r| r.setex("pending:#{server_string}", 60*5, text) end
        end

        def consume(server_string)
          key = "pending:#{server_string}"
          session = Sidekiq.redis { |r|
            value = r.get(key)
            r.del(key)
            value
          }
          JSON.parse(session) if session
        end
      end
    end
  end
end
