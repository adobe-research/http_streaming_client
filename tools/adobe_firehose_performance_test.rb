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
client = HttpStreamingClient::Client.new(compression: true)

NUM_RECORDS_PER_BATCH = 5000
MAX_RECORDS = 3600000

count = 0
totalSize = 0
intervalSize = 0
startTime = nil
lastTime = nil

puts "starting performance test run: #{Time.new.to_s}"
puts "stream: #{STREAMURL}"

startTime = lastTime = Time.new 

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

  count = count + 1
  intervalSize = intervalSize + line.size

  if count % NUM_RECORDS_PER_BATCH == 0 then

    now = Time.new
    intervalElapsedTime = now - lastTime
    totalElapsedTime = now - startTime

    totalSize = totalSize + intervalSize

    stats = Hash.new

    stats['total_records_received'] = count.to_s
    stats['total_elapsed_time_sec'] = totalElapsedTime.round(2).to_s
    stats['total_records_per_sec'] = (count / totalElapsedTime).round(2).to_s
    stats['total_kbytes_per_sec'] = (totalSize / totalElapsedTime / 1024).round(2).to_s

    stats['interval_records_received'] = NUM_RECORDS_PER_BATCH
    stats['interval_elapsed_time_sec'] = intervalElapsedTime.round(2).to_s
    stats['interval_records_per_sec'] = (NUM_RECORDS_PER_BATCH / intervalElapsedTime).round(2).to_s
    stats['interval_kbytes_per_sec'] = (intervalSize / intervalElapsedTime / 1024).round(2).to_s

    puts stats.to_json
    STDOUT.flush

    lastTime = now
    intervalSize = 0
  end

  if count == MAX_RECORDS then
    puts "finished performance test run: #{Time.new.to_s}"
    puts "total elapsed time: #{(Time.new - startTime).round(2).to_s} seconds"
    exit 0
  end

}
