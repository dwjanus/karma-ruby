require 'sinatra/base'
require 'slack-ruby-client'

class API < Sinatra::Base
  post '/events' do
    request_data = JSON.parse(request.body.read)
    case request_data['type']
    when 'url_verification'
      request_data['challenge']
    end
  end
end
