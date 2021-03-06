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
          if logged_in?
            erb :index_logged_in, :locals => {
              :title => 'Select Target',
              :our_url => request.base_url,
              :sample_path => allowed_url(''),
            }
          else
            nut = SQRL::OpaqueNut.new.to_s
            scheme = request.secure? ? URI::SQRL : URI::QRL
            auth_url = SQRL::URL.create(scheme,
              request.host+':'+request.port.to_s+'/sqrl',
              {:nut => nut, :sfn => 'SQRL::Check'}).to_s
            PendingSessionStore.sending(auth_url, {:sid => session_id, :ip => request.ip})
            erb :index_logged_out, :locals => {
              :title => 'SQRL Server Tests',
              :auth_url => auth_url,
              :qr => RQRCode::QRCode.new(auth_url, :size => 5, :level => :l),
            }
          end
        end

        post '/results' do
          unless logged_in?
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
            :signed_cert => !!params[:signed_cert],
            :allowed_url => allowed_url(params[:target_url]),
          })
          redirect to('/results/'+id)
        end

        get '/results/:id' do |id|
          results = ResultStore.load(id)
          if results
            if results['waiting']
              erb :results_waiting, :locals => {
                :title => 'Waiting for Results - ' + Rack::Utils.escape_html(results['target_url']),
              }
            else
              erb :results, :locals => {
                :title => 'Results - ' + Rack::Utils.escape_html(results['target_url']),
                :results => results,
              }
            end
          else
            status 404
            erb :results_missing, :locals => {
              :title => 'Results Missing',
            }
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
          if logged_in?
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

        get '/.well-known/sqrl_check_allowed/:idk' do |idk|
          return 204
        end

        def session_id
          session['id'] ||= SecureRandom.urlsafe_base64
        end

        def current_idk
          session['idk'] ||= PendingSessionStore.pending_idk(session_id)
        end

        def printable_idk
          SQRL::Base64.encode(current_idk)
        end

        def logged_in?
          !!current_idk
        end

        def development?
          request.host == 'localhost'
        end

        def allowed_url(target_url)
          uri = URI(target_url)
          uri.path = '/.well-known/sqrl_check_allowed/' + printable_idk
          uri.to_s
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
