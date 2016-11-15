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
          ser = JSON.generate({
            'waiting' => true,
            'target_url' => params[:target_url],
          })
          Sidekiq.redis do |r| r.setex("result:#{id}", 60*60, ser) end
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
            erb :results_missing
          end
        end

        get '/results/:id/poll' do |id|
          job = Sidekiq.redis { |r| r.exists("result:#{id}") }
          if job
            status 204
          else
            status 304
          end
        end
      end
    end
  end
end
