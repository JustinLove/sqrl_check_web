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
          results = Check::Server.run
          erb :index, :locals => { :results => results }
        end
      end
    end
  end
end
