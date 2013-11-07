require 'spec_helper'

describe HttpStreamingClient::Oauth do

  describe "generate_twitter_authorization test" do

    # using test values from https://dev.twitter.com/docs/auth/authorizing-request
    url = "https://api.twitter.com/1/statuses/update.json"
    method = "post"
    params_hash = {'include_entities' => true, 'status' => 'Hello Ladies + Gentlemen, a signed OAuth request!'}
    oauth_consumer_key = "xvz1evFS4wEEPTGEFPHBog"
    oauth_consumer_secret = "kAcSOqF21Fu85e7zjz7ZN2U4ZRhfV3WpwPAoE3Z7kBw"
    oauth_signature = "tnnArxj06cWHq44gCs1OSKk/jLY="
    oauth_token = "370773112-GmHxMAgYyLbNEtIKZeRNFsMKPR9EyMZeS9weJAEb"
    oauth_token_secret = "LswwdoUaIvS8ltyTt5jkRh4J50vUPVVHtR2YPi5kE"
    oauth_nonce = "kYjzVBB8Y0ZFabxSWbWovY3uYSQ2pTgmZeNu2VS4cg"
    oauth_timestamp = "1318622958"

    valid_authorization = 'OAuth oauth_consumer_key="xvz1evFS4wEEPTGEFPHBog", oauth_nonce="kYjzVBB8Y0ZFabxSWbWovY3uYSQ2pTgmZeNu2VS4cg", oauth_signature="tnnArxj06cWHq44gCs1OSKk%2FjLY%3D", oauth_signature_method="HMAC-SHA1", oauth_timestamp="1318622958", oauth_token="370773112-GmHxMAgYyLbNEtIKZeRNFsMKPR9EyMZeS9weJAEb", oauth_version="1.0"'

    authorization = HttpStreamingClient::Oauth::Twitter.generate_authorization(url, method, params_hash, oauth_consumer_key, oauth_consumer_secret, oauth_token, oauth_token_secret, oauth_nonce, oauth_timestamp)

    subject { authorization }
    it { should_not be_nil }
    it { should eq valid_authorization }
  end

end
