require 'spec_helper'


describe HttpStreamingClient do

  # currently disabled, requires a server that can be killed to simulate dropped connections

  it "should receive exactly 10 messages, no reconnect" do
  #it "should receive exactly 10 messages, no reconnect", :disabled => true do
  
    count = 0
    client = HttpStreamingClient::Client.new(compression: false)
    response = client.get("http://localhost:3000/outbounds/consumer/1") { |line|
      logger.debug "line received: #{line}"
      count = count + 1
    }
    expect(response).to be_true
    expect(count).to be(10)
  end
  
  it "should reconnect on any error or EOF" do

    client = HttpStreamingClient::Client.new(compression: false, reconnect: true, reconnect_attempts: 5, reconnect_interval: 1)
    count = 0
    response = client.get("http://localhost:3000/outbounds/consumer/1") { |line|
      logger.debug "line received: #{line}"
      count = count + 1
      client.interrupt if count > 20
    }
  end

end
