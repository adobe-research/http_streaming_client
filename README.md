# HttpStreamingClient

Ruby HTTP client with support for HTTP 1.1 streaming, GZIP and zlib compressed streams, and chunked transfer encoding. Includes extensible OAuth support for the following:

* Adobe Analytics Firehose
* Twitter Streaming APIs

## Ruby Version

MRI ruby-2.0.0-p247. If you need it, install via rvm: https://rvm.io/

## Installation (local gem bundle/install)

Execute the following to bundle the gem:

    $ gem build http_streaming_client.gemspec

Then install the gem with:

    $ gem install http_streaming_client

## Installation (via Adobe github)

Add this line to your application's Gemfile:

    gem 'http_streaming_client', :git => 'git@github.com:adobe-research/http_streaming_client.git'

And then execute:

    $ bundle install

## Installation (rubyforge -- pending)

Add this line to your application's Gemfile:

    gem 'http_streaming_client'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install http_streaming_client

## Version

Current release version: 0.8.0 (see <a href="https://github.com/adobe-research/http_streaming_client/releases">RELEASES</a>)

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

## Examples

Take a look at

* spec/client_spec.rb
* tools/adobe_firehose.rb
* tools/adobe_firehose_performance_test.rb
* tools/twitter_firehose.rb
* tools/twitter_firehose_performance_test.rb

## TODO

* connection management with reconnect functions
* load/memory testing

## Fixed Issues

* See [![CHANGELOG](CHANGELOG)](CHANGELOG)

## License

Licensed under the Apache Software License 2.0. See [![LICENSE](LICENSE)](LICENSE) file.
