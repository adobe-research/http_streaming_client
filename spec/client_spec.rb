require 'spec_helper'

describe HttpStreamingClient do

  describe "static get test" do
    response = HttpStreamingClient::Client.get "http://www.google.com/"
    logger.debug "response: #{response}"
    subject { response }
    it { should_not be_nil}
  end

  describe "client instance get test" do
    client = HttpStreamingClient::Client.new
    response = client.get "http://www.google.com/"
    logger.debug "response: #{response}"
    subject { response }
    it { should_not be_nil}
  end

  describe "static get test HTTPS" do
    response = HttpStreamingClient::Client.get("https://www.google.com/") { |chunk| logger.debug "got a chunk" }
    logger.debug "response: #{response}"
    subject { response }
    it { should_not be_nil}
  end

  describe "static get failure test" do
    it "should fail if host not found" do
      expect { HttpStreamingClient::Client.get "http://www.blooglefailure.com/" }.to raise_error(SocketError)
    end
  end

  describe "static post test" do
    response = HttpStreamingClient::Client.post "http://posttestserver.com/post.php", "v=1.0&rsz=large&hl=en&geo=25187&key=ABQIAAAAh-n5SAB-cUnY3DufmfhdwBQuvo9pmDsxzxSHtaSRC_4ezr2lsRTOljpJVo81DJYBcnI00Fwk9xTdWQ"
    logger.debug "response: #{response}"
    subject { response }
    it { should_not be_nil}
  end
  
  describe "client instance post test" do
    client = HttpStreamingClient::Client.new
    params = Hash.new
    params['v'] = "1.0"
    params['rsz'] = "large"
    params['hl'] = "geo"
    params['geo'] = "25187"
    response = client.post "http://posttestserver.com/post.php", params
    subject { response }
    it { should_not be_nil}
  end

end
