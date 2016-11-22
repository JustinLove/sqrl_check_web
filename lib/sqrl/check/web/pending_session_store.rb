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

        def login(sid, idk)
          Sidekiq.redis do |r| r.setex("login:#{sid}", 60*5, idk) end
        end

        def pending_idk(sid)
          Sidekiq.redis { |r| r.get("login:#{sid}") }
        end

        def reset_session(sid)
          Sidekiq.redis do |r| r.del("login:#{sid}") end
        end

        def generate_token(idk)
          token = SecureRandom.urlsafe_base64
          Sidekiq.redis do |r| r.setex("token:#{token}", 60*5, idk) end
          token
        end

        def consume_token(token)
          key = "token:#{token}"
          Sidekiq.redis { |r|
            value = r.get(key)
            r.del(key)
            value
          }
        end
      end
    end
  end
end
