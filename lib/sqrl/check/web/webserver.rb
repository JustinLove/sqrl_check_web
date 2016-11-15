require 'sqrl/check/server'
require 'sqrl/check/web/serialize_reporter'
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

        get '/results' do
          job = JSON.generate(SerializeReporter.new(Check::Server.run(
            :target_url => params[:target_url],
            :signed_cert => !!params[:signed_cert]
          )).to_h)
          results = JSON.parse(job)
          erb :results, :locals => {
            :target_url => params[:target_url],
            :results => results
          }
        end
      end
    end
  end
end
