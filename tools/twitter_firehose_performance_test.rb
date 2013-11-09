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

NUM_RECORDS_PER_BATCH = 1000
MAX_RECORDS = 50000

count = 0
totalSize = 0
intervalSize = 0
startTime = nil
lastTime = nil

puts "starting performance test run: #{Time.new.to_s}"

startTime = lastTime = Time.new 

client = HttpStreamingClient::Client.new(compression: true)
response = client.get(url, {:headers => {'Authorization' => "#{authorization}" }}) { |line|

  if line.nil? then
    puts "error:nil line received"
    next
  end

  if line.size == 0 then
    puts "error:zero length line received"
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
    
    lastTime = now
    intervalSize = 0
  end
  
  if count == MAX_RECORDS then
    puts "finished performance test run: #{Time.new.to_s}"
    puts "total elapsed time: #{(Time.new - startTime).round(2).to_s} seconds"
    exit 0
  end
  
}
