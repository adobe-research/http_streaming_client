###########################################################################
##
## http_streaming_client
##
## Ruby HTTP client with support for HTTP 1.1 streaming, GZIP compressed
## streams, and chunked transfer encoding. Includes extensible OAuth
## support for the Adobe Analytics Firehose and Twitter Streaming APIs.
##
## David Tompkins -- 11/8/2013
## tompkins@adobe_dot_com
##
###########################################################################
##
## Copyright (c) 2013 Adobe Systems Incorporated. All rights reserved.
##
## Licensed under the Apache License, Version 2.0 (the "License");
## you may not use this file except in compliance with the License.
## You may obtain a copy of the License at
##
## http://www.apache.org/licenses/LICENSE-2.0
##
## Unless required by applicable law or agreed to in writing, software
## distributed under the License is distributed on an "AS IS" BASIS,
## WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
## See the License for the specific language governing permissions and
## limitations under the License.
##
###########################################################################

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
	response = HttpStreamingClient::Client.post(uri, params_string, {:headers => {'Authorization' => "Basic #{basicAuth}"}})
	response_json = JSON.parse(response)

	logger.debug "token API response: #{response_json}"

	authorization = response_json['access_token']

	logger.debug "authorization header: #{authorization}"

	return authorization
      end

    end
  end
end
