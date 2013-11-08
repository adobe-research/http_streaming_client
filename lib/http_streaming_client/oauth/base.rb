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
require 'logger'
require 'uri'
require 'securerandom'

require "http_streaming_client/custom_logger"

module HttpStreamingClient

  module Oauth

    class Base

      def self.logger
	HttpStreamingClient.logger
      end

      protected

      def self.percent_encode(s)
	return URI.escape(s, Regexp.new("[^#{URI::PATTERN::UNRESERVED}]") ).gsub('*', '%2A').gsub('!', '%21')
      end

      # lexigraphically sort query params with percent encoding applied
      def self.sort_and_percent_encode(params_hash)
	pairs = []
	params_hash.sort.each { |key, val| pairs.push("#{percent_encode(key)}=#{percent_encode(val.to_s)}") }
	return pairs.join('&')
      end

      def self.generate_nonce
	return SecureRandom.hex
      end

      def self.generate_timestamp
	return Time.new.to_i.to_s
      end

    end
  end
end
