require 'bundler/setup'
require 'logger'

require 'http/oauth'
require 'http/streaming/client'
require 'http/custom_logger'

include Http::Oauth
include Http::Streaming::Client
include Http::CustomLogger

logger.console = true
logger.level = Logger::DEBUG
logger.logfile = false

if ARGV.size != 7 then
  puts "Usage generate_twitter_authorization_header.rb method url params_string consumer_key consumer_secret oauth_token oauth_token_secret\n"
  exit(1)
end

method = ARGV[0]
url = ARGV[1]
params_hash = Hash.new
ARGV[2].split("&").each { |p| params_hash[p.split("=")[0]] = p.split("=")[1] } unless ARGV[2].empty?
oauth_consumer_key = ARGV[3]
oauth_consumer_secret = ARGV[4]
oauth_token = ARGV[5]
oauth_token_secret = ARGV[6]

authorization = generate_twitter_authorization(url, method, params_hash, oauth_consumer_key, oauth_consumer_secret, oauth_token, oauth_token_secret)
puts "Authorization: #{authorization}"
