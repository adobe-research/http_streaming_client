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
