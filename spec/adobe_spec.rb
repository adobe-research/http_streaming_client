require 'spec_helper'
require 'json'
require 'zlib'
require 'uri'
require 'timeout'

require 'http_streaming_client/credentials/adobe'
include HttpStreamingClient::Credentials::Adobe

describe HttpStreamingClient do

  describe "adobe firehose streaming get test, no compression" do

    url = TOKENAPIHOST
    authorization = HttpStreamingClient::Oauth::Adobe.generate_authorization(url, USERNAME, PASSWORD, CLIENTID, CLIENTSECRET)

    subject { authorization }
    it { should_not be_nil}
    it { should be_instance_of(String) }

    line_count = 0

    it "should successfully retrieve JSON records from the firehose" do
      expect {
	client = HttpStreamingClient::Client.new(compression: false)
	begin
	  status = Timeout::timeout(TIMEOUT_SEC) {
	    response = client.get(STREAMURL, {:headers => {'Authorization' => "Bearer #{authorization}" }}) { |line|

	    if line.nil? then
	      logger.debug "error:nil line received"
	      next
	    end

	    if line.size == 0 then
	      logger.debug "error:zero length line received"
	      next
	    end

	    line_count = line_count + 1

	    if line.eql? "\r\n" then
	      logger.debug "Server ping received"
	    else
	      logger.debug "#{JSON.parse(line).to_s}"
	    end

	    client.interrupt if line_count > NUM_JSON_RECORDS_TO_RECEIVE }
	  }
	rescue Timeout::Error
	  logger.debug "Timeout occurred, #{TIMEOUT_SEC} seconds elapsed"
	  client.interrupt
	end
      }.to_not raise_error
    end
  end

  describe "adobe firehose streaming get test, no compression, no block" do

    url = TOKENAPIHOST
    authorization = HttpStreamingClient::Oauth::Adobe.generate_authorization(url, USERNAME, PASSWORD, CLIENTID, CLIENTSECRET)

    subject { authorization }
    it { should_not be_nil}
    it { should be_instance_of(String) }

    line_count = 0

    it "should successfully retrieve JSON records from the firehose" do
      expect {
	client = HttpStreamingClient::Client.new(compression: false)
	begin
	  status = Timeout::timeout(TIMEOUT_SEC) {
	    response = client.get(STREAMURL, {:headers => {'Authorization' => "Bearer #{authorization}" }})
	  }
	rescue Timeout::Error
	  logger.debug "Timeout occurred, #{TIMEOUT_SEC} seconds elapsed"
	  client.interrupt
	end
      }.to_not raise_error
    end
  end

  describe "adobe firehose streaming get test, GZIP compression" do

    url = TOKENAPIHOST
    authorization = HttpStreamingClient::Oauth::Adobe.generate_authorization(url, USERNAME, PASSWORD, CLIENTID, CLIENTSECRET)

    subject { authorization }
    it { should_not be_nil}
    it { should be_instance_of(String) }

    line_count = 0

    it "should successfully retrieve decompressed JSON records from the firehose" do
      expect {
	client = HttpStreamingClient::Client.new(compression: true)
	begin
	  status = Timeout::timeout(TIMEOUT_SEC) {
	    response = client.get(STREAMURL, {:headers => {'Authorization' => "Bearer #{authorization}" }}) { |line|

	    if line.nil? then
	      logger.debug "error:nil line received"
	      next
	    end

	    if line.size == 0 then
	      logger.debug "error:zero length line received"
	      next
	    end

	    line_count = line_count + 1

	    if line.eql? "\r\n" then
	      logger.debug "Server ping received"
	    else
	      logger.debug "#{JSON.parse(line).to_s}"
	    end

	    client.interrupt if line_count > NUM_JSON_RECORDS_TO_RECEIVE }
	  }
	rescue Timeout::Error
	  logger.debug "Timeout occurred, #{TIMEOUT_SEC} seconds elapsed"
	  client.interrupt
	end
      }.to_not raise_error
    end

  end

  #describe "adobe firehose streaming get unauthorized failure" do
  #it "should fail if authorization not provided" do
  #expect { get STREAMURL }.to raise_error(HttpError)
  #end
  #end

end
