require 'bundler/setup'
require 'logger'
require 'base64'

require 'http/streaming/client'
require 'http/custom_logger'

include Http::Streaming::Client
include Http::CustomLogger

logger.console = true
logger.level = Logger::DEBUG
logger.logfile = false

if ARGV.size != 2 then
  puts "Usage generate_twitter_bearer_token.rb app_key app_secret\n"
  exit(1)
end

key = URI::encode(ARGV[0])
secret = URI::encode(ARGV[1])
encoded = Base64.strict_encode64("#{key}:#{secret}")

# API spec states that grant_type should be in the post body...but api.twitter.com seems to see it only if it is a URL parameter...
response = post("https://api.twitter.com/oauth2/token?grant_type=client_credentials", "grant_type=client_credentials", headers: {'Authorization' => "Basic #{encoded}" })
puts response
