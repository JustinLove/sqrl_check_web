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
      end
    end
  end
end
