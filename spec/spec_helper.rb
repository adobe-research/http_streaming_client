require 'bundler/setup'
require 'logger'

require 'simplecov'
SimpleCov.start do
  add_filter "/spec/"
end

require 'http_streaming_client'

NUM_JSON_RECORDS_TO_RECEIVE = 5

RSpec.configure do |config|

  HttpStreamingClient.logger.console = true
  HttpStreamingClient.logger.level = Logger::DEBUG
  HttpStreamingClient.logger.logfile = true

end

def logger
  HttpStreamingClient.logger
end
