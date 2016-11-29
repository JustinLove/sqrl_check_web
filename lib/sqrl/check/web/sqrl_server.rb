require 'sqrl/check/web/pending_session_store'
require 'sqrl/query_parser'
require 'sqrl/response_generator'
require 'sqrl/opaque_nut'

module SQRL
  module Check
    module Web
      class SqrlServer
        def initialize(request)
          @web_request = request
          @command_failed = true
          @function_not_supported = true
          @pending_session = get_pending_session
          @session_idk = nil
          if pending_session
            @session_idk = PendingSessionStore.pending_idk(pending_session['sid'])
          end
        end

        attr_reader :web_request
        attr_reader :pending_session
        attr_reader :session_idk

        def execute
          @command_failed = !execute_command

          self
        end

        def update_session(session)
          PendingSessionStore.sending(sqrl_response.server_string, pending_session) if pending_session
        end

        def execute_command
          @function_not_supported = false
          case sqrl_request.commands.first
          when 'query'; query
          when 'ident'; ident
          else
            @function_not_supported = true
            false
          end
        end

        def query
          session? && ids?
        end

        def ident
          return false unless login_capable? && ids?

          @session_idk = sqrl_request.idk
          PendingSessionStore.login(pending_session['sid'], sqrl_request.idk)
          pending_session.delete('sid') if sqrl_request.opt?('cps')

          true
        end

        def response_body
          sqrl_response.response_body
        end

        def sqrl_request
          @sqrl_request ||= SQRL::QueryParser.new(@body = web_request.body.read)
        rescue ArgumentError => e
          p @body, e
          #puts e.backtrace
          nil
        end

        def sqrl_response
          @sqrl_response ||= SQRL::ResponseGenerator.new(res_nut, flags, fields)
        end

        def res_nut
          @res_nut ||= SQRL::OpaqueNut.new.to_s
        end

        def get_pending_session
          PendingSessionStore.consume(sqrl_request.server_string)
        rescue ArgumentError => e
          p sqrl_request.params['server'], e
          #puts e.backtrace
          nil
        end

        def flags
          {
            :id_match => session_idk && session_idk == sqrl_request.idk,
            :previous_id_match => session_idk && session_idk == sqrl_request.pidk,
            :ip_match => pending_session && pending_session['ip'] == web_request.ip,
            :command_failed => @command_failed,
            :function_not_supported => @function_not_supported,
          }
        end

        def fields
          f = {
            'qry' => '/sqrl',
          }
          if sqrl_request.opt?('cps') && !sqrl_request.commands.include?('query')
            token = PendingSessionStore.generate_token(sqrl_request.idk)
            f['url'] = "#{web_request.base_url}/token/#{token}"
          end
          f
        end

        def session?
          !!pending_session
        end

        def ids?
          @ids_valid ||= sqrl_request.valid?
        end

        def login_capable?
          session? && pending_session['sid']
        end
      end
    end
  end
end
