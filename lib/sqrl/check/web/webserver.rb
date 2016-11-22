require 'sqrl/check/web/sidekiq_config'
require 'sqrl/check/web/result_store'
require 'sqrl/check/web/pending_session_store'
require 'sqrl/check/web/sqrl_server'
require 'sqrl/opaque_nut'
require 'sqrl/url'
require 'sqrl/base64'
require 'sinatra/base'
require 'rqrcode'
require 'json'

module SQRL
  module Check
    module Web
      class Webserver < Sinatra::Base
        enable :sessions
        if ENV['SESSION_SECRET']
          set :session_secret, ::Base64.decode64(ENV['SESSION_SECRET'])
        end

        configure do 
          STDOUT.sync = true
        end

        get '/' do
          if current_idk
            erb :index_logged_in, :locals => {
              :current_idk => SQRL::Base64.encode(current_idk),
            }
          else
            nut = SQRL::OpaqueNut.new.to_s
            scheme = request.secure? ? URI::SQRL : URI::QRL
            auth_url = SQRL::URL.create(scheme,
              request.host+':'+request.port.to_s+'/sqrl',
              {:nut => nut, :sfn => 'SQRL::Test'}).to_s
            PendingSessionStore.sending(auth_url, {:sid => session_id, :ip => request.ip})
            erb :index_logged_out, :locals => {
              :auth_url => auth_url,
              :qr => RQRCode::QRCode.new(auth_url, :size => 5, :level => :l),
            }
          end
        end

        post '/results' do
          unless current_idk
            status 401
            redirect to('/')
            return
          end

          id = SecureRandom.urlsafe_base64
          ResultStore.save(id, {
            'waiting' => true,
            'target_url' => params[:target_url],
          })
          TestWorker.perform_async(id, {
            :target_url => params[:target_url],
            :signed_cert => !!params[:signed_cert]
          })
          redirect to('/results/'+id)
        end

        get '/results/:id' do |id|
          results = ResultStore.load(id)
          if results
            if results['waiting']
              erb :results_waiting, :locals => {
                :target_url => results['target_url'],
              }
            else
              erb :results, :locals => {
                :target_url => results['target_url'],
                :results => results,
              }
            end
          else
            status 404
            erb :results_missing
          end
        end

        get '/results/:id/poll' do |id|
          job = ResultStore.load(id)
          if job && job['waiting']
            status 304
          else
            status 204
          end
        end

        post '/logout' do
          reset_session
          redirect to('/')
        end

        get '/token/:token' do |token|
          idk = PendingSessionStore.consume_token(token)
          if idk
            reset_session
            session['idk'] = idk
            redirect to('/')
          else
            status 404
          end
        end

        get '/poll' do
          if current_idk
            status 204
          else
            status 401
          end
        end

        post '/sqrl' do
          ss = SqrlServer.new(request)
          ss.execute
          ss.update_session(session)
          return ss.response_body
        end

        def session_id
          session['id'] ||= SecureRandom.urlsafe_base64
        end

        def current_idk
          session['idk'] ||= PendingSessionStore.pending_idk(session_id)
        end

        def reset_session
          PendingSessionStore.reset_session(session_id)
          session.delete('idk')
          session.delete('id')
        end
      end
    end
  end
end
