require 'sqrl/check/web/sidekiq_config'
require 'sqrl/check/web/result_store'
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
      end
    end
  end
end
