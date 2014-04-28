# HttpStreamingClient [![Coverage Status](https://coveralls.io/repos/adobe-research/http_streaming_client/badge.png)](https://coveralls.io/r/adobe-research/http_streaming_client) [![Gem Version](https://badge.fury.io/rb/http_streaming_client.png)](http://badge.fury.io/rb/http_streaming_client)

Ruby HTTP client with support for HTTP 1.1 streaming, GZIP and zlib compressed streams, and chunked transfer encoding. Includes extensible OAuth support for the following:

* Adobe Analytics Firehose
* Twitter Streaming APIs

## Ruby Version

MRI ruby-2.0.0-p451 and JRuby jruby-1.7.12. Install via rvm: https://rvm.io/

## Installation

Add this line to your application's Gemfile:

    gem 'http_streaming_client'

And then execute:

    $ bundle install

Or install it directly via gem with:

    $ gem install http_streaming_client

## Simple Example

Twitter Firehose Sample Stream:

```ruby
require 'http_streaming_client'

twitter_stream_url = "https://stream.twitter.com/1.1/statuses/sample.json"

# Generate the HMAC-SHA1 Twitter OAuth authorization header
authorization = HttpStreamingClient::Oauth::Twitter.generate_authorization(twitter_stream_url, "get", {}, OAUTH_CONSUMER_KEY, OAUTH_CONSUMER_SECRET, OAUTH_TOKEN, OAUTH_TOKEN_SECRET)

# Configure the client
client = HttpStreamingClient::Client.new(compression: true, reconnect: true, reconnect_interval: 10, reconnect_attempts: 60)

# Open the connection and start processing messages
response = client.get(twitter_stream_url, {:headers => {'Authorization' => "#{authorization}" }}) { |line|
  logger.info "Received a line that we could parse into JSON if we want: #{line}"
  client.interrupt if we_want_to_stop_receiving_messages?
}
```

For more examples, take a look at

* spec/client_spec.rb
* tools/adobe_firehose.rb
* tools/adobe_firehose_performance_test.rb
* tools/twitter_firehose.rb
* tools/twitter_firehose_performance_test.rb

## Client Configuration Options

The following options are supported as hash option parameters for HttpStreamingClient::Client.new:

GZip Compression

    compression: true/false (default: true)

Automatic Socket Reconnect Functions

    reconnect: true/false (default: false)

Reconnect Interval

    reconnect_interval: interval_seconds (default: 1 second)

Maximum Reconnect Attempts

    reconnect_attempts: num_attempts (default: 10)

## Logging

HTTP protocol trace logging is available as :debug level logging. The gem supports configurable logging to both STDOUT and a log file, and includes a Railtie to use Rails.logger when the gem is included in a Rails application.

To configure gem logging to STDOUT, specify the following in your code:

    HttpStreamingClient.logger.console = true

To configure gem logging to a log file named "test.log", specify the following in your code:

    HttpStreamingClient.logger.logfile = true

And to set the log level, specify the following in your code (e.g. to set the log level to :debug):

    HttpStreamingClient.logger.level = Logger::DEBUG

## Streaming Service Credentials

The command line tools for the Adobe Analytics Firehose and Twitter's Streaming APIs require valid Adobe and Twitter credentials. Unit tests execute against the Twitter sample firehose and the Adobe Analytics Firehose and also require valid service credentials.

To configure Adobe Analytics Firehose credentials, copy lib/http_streaming_client/credentials/adobe.rb.sample to lib/http_streaming_client/credentials/adobe.rb, and edit the file to include valid Adobe Analytics Firehose API credentials.

To configure Twitter credentials, copy lib/http_streaming_client/credentials/twitter.rb.sample to lib/http_streaming_client/credentials/twitter.rb, and edit the file to include valid Twitter API credentials.

## Command Line Tools

To run the sample Adobe Analytics Firehose client, execute the following after configuring valid service credentials:

    $ ruby tools/adobe_firehose.rb

To run the Adobe Analytics Firehose performance test client, execute the following after configuring valid service credentials:

    $ ruby tools/adobe_firehose_performance_test.rb

The performance test client will emit performance test metrics to stdout as JSON objects with the following format:

    {"total_records_received":"22000","total_elapsed_time_sec":"118.98","total_records_per_sec":"184.9","total_kbytes_per_sec":"307.5","interval_records_received":1000,"interval_elapsed_time_sec":"5.0","interval_records_per_sec":"200.15","interval_kbytes_per_sec":"331.89"}

The batch size per metric output and the total number of records in the performance test run can be configured within the script.

To run the sample Twitter Firehose client, execute the following after configuring valid service credentials:

    $ ruby tools/twitter_firehose.rb

To run the Twitter Firehose performance test client, execute the following after configuring valid service credentials:

    $ ruby tools/twitter_firehose_performance_test.rb

The performance metrics output and tunable settings in the script are identical to those for the Adobe Analytics Firehose performance test client.

All tools emit JSON object streams to stdout.

## Unit Test Coverage

Unit test suite implemented with rspec and simplecov. Run via:

    $ rake
or:

    $ rspec

Individual test suites in the spec directory can be run via:

    $ rspec spec/<spec filename>.spec

An HTML coverage report is generated at the end of a full test run in the coverage directory.

## Fixed Issues

* See [![CHANGELOG](CHANGELOG)](CHANGELOG)

## License

Licensed under the Apache Software License 2.0. See [![LICENSE](LICENSE)](LICENSE) file.
