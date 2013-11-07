require 'bundler/setup'
require 'openssl'
require 'base64'
require 'uri'
require 'json'

require 'http_streaming_client/oauth/base'

module HttpStreamingClient
  module Oauth

    class Adobe < Base

      def self.generate_authorization(uri, username, password, clientId, clientSecret)

	logger.debug "generate_authorization: #{uri}"

	params = Hash.new
	params['grant_type'] = "password"
	params['username'] = username
	params['password'] = password
	params_string = sort_and_percent_encode(params)

	logger.debug "params_string: #{params_string}"

	basicAuth = "#{clientId}:#{clientSecret}"
	basicAuth = Base64.encode64(basicAuth).chomp.gsub(/\n/, '')

	logger.debug "base64 encoded authorization: #{basicAuth}"

	uri = URI.parse(uri) if uri.is_a?(String)
	url_string = "#{uri.scheme}://#{uri.host}#{uri.path}"

	# POST to uri
	response = post(uri, params_string, {:headers => {'Authorization' => "Basic #{basicAuth}"}})
	response_json = JSON.parse(response)

	logger.debug "token API response: #{response_json}"

	authorization = response_json['access_token']

	logger.debug "authorization header: #{authorization}"

	return authorization
      end

    end
  end
end
