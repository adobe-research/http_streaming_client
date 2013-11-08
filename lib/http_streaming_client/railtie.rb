require 'http_streaming_client'

module HttpStreamingClient
  class Railties < ::Rails::Railtie
    initializer 'railties.configure_rails_initialization' do
      puts "RAILTIE CALLED"
      HttpStreamingClient.logger = Rails.logger
    end
  end
end
