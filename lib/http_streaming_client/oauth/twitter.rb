require 'bundler/setup'
require 'openssl'
require 'base64'
require 'uri'

require 'http_streaming_client/oauth/base'

module HttpStreamingClient
  module Oauth

    class Twitter < Base

      def self.generate_authorization(uri, method, params_hash, oauth_consumer_key, oauth_consumer_secret, oauth_token, oauth_token_secret, oauth_nonce = nil, oauth_timestamp = nil)

	logger.debug "generate_twitter_authorization: #{uri}"

	oauth_nonce = generate_nonce unless !oauth_nonce.nil?
	oauth_timestamp = generate_timestamp unless !oauth_timestamp.nil?
	oauth_signature_method = "HMAC-SHA1"
	oauth_version = "1.0"

	params = Hash.new
	params['oauth_consumer_key'] = oauth_consumer_key
	params['oauth_nonce'] = oauth_nonce
	params['oauth_signature_method'] = oauth_signature_method
	params['oauth_timestamp'] = oauth_timestamp
	params['oauth_token'] = oauth_token
	params['oauth_version'] = oauth_version
	params.merge! params_hash unless params_hash.nil?
	params_string = sort_and_percent_encode(params)

	logger.debug "params_string: #{params_string}"

	uri = URI.parse(uri) if uri.is_a?(String)
	url_string = "#{uri.scheme}://#{uri.host}#{uri.path}"

	signature_base = "#{method.upcase}&"
	signature_base << "#{percent_encode(url_string)}&"
	signature_base << "#{percent_encode(params_string)}"

	logger.debug "signature base string: #{signature_base}"

	digest = OpenSSL::Digest::Digest.new('sha1')
	hmac = OpenSSL::HMAC.digest(digest, "#{percent_encode(oauth_consumer_secret)}&#{percent_encode(oauth_token_secret)}", signature_base)
	oauth_signature = Base64.encode64(hmac).chomp.gsub(/\n/, '')

	logger.debug "oauth signature: #{oauth_signature}"

	authorization = 'OAuth '
	authorization << "oauth_consumer_key=\"#{percent_encode(oauth_consumer_key)}\", "
	authorization << "oauth_nonce=\"#{percent_encode(oauth_nonce)}\", "
	authorization << "oauth_signature=\"#{percent_encode(oauth_signature)}\", "
	authorization << "oauth_signature_method=\"#{percent_encode(oauth_signature_method)}\", "
	authorization << "oauth_timestamp=\"#{percent_encode(oauth_timestamp)}\", "
	authorization << "oauth_token=\"#{percent_encode(oauth_token)}\", "
	authorization << "oauth_version=\"#{percent_encode(oauth_version)}\""

	logger.debug "authorization header: #{authorization}"

	return authorization
      end

    end
  end
end
