require 'bundler/setup'
require 'logger'
require 'json'

require 'http_streaming_client'

HttpStreamingClient.logger.console = false
HttpStreamingClient.logger.logfile = false

require 'http_streaming_client/credentials/adobe'
include HttpStreamingClient::Credentials::Adobe

url = TOKENAPIHOST
authorization = HttpStreamingClient::Oauth::Adobe.generate_authorization(url, USERNAME, PASSWORD, CLIENTID, CLIENTSECRET)
puts "#{TOKENAPIHOST}:access token: #{authorization}"
client = HttpStreamingClient::Client.new(compression: false)
response = client.get(STREAMURL, {:headers => {'Authorization' => "Bearer #{authorization}" }}) { |line|

    if line.nil? then
      puts "error:nil line received"
      next
    end

    if line.size == 0 then
      puts "error:zero length line received"
      next
    end

    if line.eql? "\r\n" or line.eql? "\r\n\r\n" then
      puts "Server ping received"
      next
    end

    begin
      json = JSON.parse(line)
      puts json.to_s
    rescue Exception => e
      puts "exception:#{e.message}:line-->#{line}<--"
    end
  }
