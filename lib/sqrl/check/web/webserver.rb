require 'sqrl/check/web/sidekiq_config'
require 'sinatra/base'
require 'json'

module SQRL
  module Check
    module Web
      class Webserver < Sinatra::Base
        enable :sessions

        configure do 
          STDOUT.sync = true
        end

        get '/' do
          erb :index
        end

        post '/results' do
          id = SecureRandom.urlsafe_base64
          TestWorker.perform_async(id, {
            :target_url => params[:target_url],
            :signed_cert => !!params[:signed_cert]
          })
          redirect to('/results/'+id)
        end

        get '/results/:id' do |id|
          job = Sidekiq.redis { |r| r.get("result:#{id}") }
          if job
            results = JSON.parse(job)
            erb :results, :locals => {
              :target_url => params[:target_url],
              :results => results
            }
          else
            erb :results_waiting, :locals => {
              :target_url => params[:target_url],
            }
          end
        end
      end
    end
  end
end
