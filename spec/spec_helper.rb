require 'bundler/setup'
require 'logger'

require 'coveralls'
Coveralls.wear! if ENV["COVERALLS"]

require 'simplecov'
SimpleCov.start do
  add_filter "/spec/"
  add_filter "/lib/http_streaming_client/credentials/"
end

require 'http_streaming_client'

NUM_JSON_RECORDS_TO_RECEIVE = 5
TIMEOUT_SEC = 90

RSpec.configure do |config|

  HttpStreamingClient.logger.console = true
  HttpStreamingClient.logger.level = Logger::DEBUG
  HttpStreamingClient.logger.logfile = true
  HttpStreamingClient.logger.tag = "rspec"

  config.filter_run_excluding disabled: true

end

def logger
  HttpStreamingClient.logger
end
