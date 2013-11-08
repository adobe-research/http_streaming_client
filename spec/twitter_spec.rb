require 'spec_helper'
require 'json'
require 'zlib'
require 'uri'

require 'http_streaming_client/credentials/twitter'
include HttpStreamingClient::Credentials::Twitter

describe HttpStreamingClient do

  describe "twitter firehose streaming get test, no compression" do
    url = "https://stream.twitter.com/1.1/statuses/sample.json"
    authorization = HttpStreamingClient::Oauth::Twitter.generate_authorization(url, "get", {}, OAUTH_CONSUMER_KEY, OAUTH_CONSUMER_SECRET, OAUTH_TOKEN, OAUTH_TOKEN_SECRET)

    subject { authorization }
    it { should_not be_nil}
    it { should be_instance_of(String) }

    count = 0

    it "should successfully retrieve JSON records from the firehose" do
      expect {
	client = HttpStreamingClient::Client.new(compression: false)
	response = client.get(url, {:headers => {'Authorization' => "#{authorization}" }}) { |line|
	count = count + 1
	if count > NUM_JSON_RECORDS_TO_RECEIVE then
	  client.interrupt
	  next
	end
	logger.debug "json: #{JSON.parse(line).to_s}" }
      }.to_not raise_error
    end

  end

  describe "twitter firehose streaming get test, GZIP compression" do
    url = "https://stream.twitter.com/1.1/statuses/sample.json"
    authorization = HttpStreamingClient::Oauth::Twitter.generate_authorization(url, "get", {}, OAUTH_CONSUMER_KEY, OAUTH_CONSUMER_SECRET, OAUTH_TOKEN, OAUTH_TOKEN_SECRET)

    subject { authorization }
    it { should_not be_nil}
    it { should be_instance_of(String) }

    count = 0

    it "should successfully retrieve decompressed JSON records from the firehose" do
      expect {
	client = HttpStreamingClient::Client.new(compression: true)
	response = client.get(url, {:headers => {'Authorization' => "#{authorization}" }}) { |line|
	count = count + 1
	if count > NUM_JSON_RECORDS_TO_RECEIVE then
	  client.interrupt
	  next
	end
	logger.debug "json: #{JSON.parse(line).to_s}" }
      }.to_not raise_error
    end
  end

  describe "twitter firehose streaming get unauthorized failure" do
    it "should fail if authorization not provided" do
      expect { HttpStreamingClient::Client.get "https://stream.twitter.com/1.1/statuses/sample.json" }.to raise_error(HttpStreamingClient::HttpError)
    end
  end

end
