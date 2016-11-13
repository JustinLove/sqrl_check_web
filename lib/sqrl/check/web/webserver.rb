require 'sqrl/check/server'
require 'sinatra/base'

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
          results = Check::Server.run(:target_url => params[:target_url])
          erb :results, :locals => { :target_url => params[:target_url], :results => results }
        end
      end
    end
  end
end
