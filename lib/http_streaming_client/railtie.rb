require 'http_streaming_client'

module HttpStreamingClient
  class Railties < ::Rails::Railtie
    initializer 'Rails logger' do
      HttpStreamingClient.logger = Rails.logger
    end
  end
end
