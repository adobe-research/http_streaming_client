require 'bundler/setup'
require 'logger'
require 'json'

require 'http_streaming_client'

require 'http_streaming_client/credentials/twitter'
include HttpStreamingClient::Credentials::Twitter

HttpStreamingClient.logger.console = false
HttpStreamingClient.logger.logfile = false

url = "https://stream.twitter.com/1.1/statuses/sample.json"
authorization = HttpStreamingClient::Oauth::Twitter.generate_authorization(url, "get", {}, OAUTH_CONSUMER_KEY, OAUTH_CONSUMER_SECRET, OAUTH_TOKEN, OAUTH_TOKEN_SECRET)
puts "authorization: #{authorization}"
client = HttpStreamingClient::Client.new(compression: true)
response = client.get(url, {:headers => {'Authorization' => "#{authorization}" }}) { |line| puts "#{JSON.parse(line).to_s}/n" }
