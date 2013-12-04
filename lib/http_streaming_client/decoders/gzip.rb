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

require 'zlib'

module HttpStreamingClient

  module Decoders

    class GZip

      def logger
	HttpStreamingClient.logger
      end

      def initialize(&packet_callback)
	logger.debug "GZip:initialize"
	@packet_callback = packet_callback
      end

      def <<(compressed_packet)
	return unless compressed_packet && compressed_packet.size > 0
	decompressed_packet = decompress(compressed_packet)
	process_decompressed_packet(decompressed_packet)
      end

      def close
	logger.debug "GZip:close"
	decompressed_packet = ""
	begin
	  @gzip ||= Zlib::GzipReader.new @buf
	  decompressed_packet = @gzip.readline
	rescue Zlib::Error
	  raise DecoderError
	end
	process_decompressed_packet(decompressed_packet)
      end

      protected

      def decompress(compressed_packet)
	@buf ||= GZipBufferIO.new
	@buf << compressed_packet

	# pass at least 2k bytes to GzipReader to avoid zlib EOF
	if @buf.size > 2048
	  @gzip ||= Zlib::GzipReader.new @buf
	  @gzip.readline
	end
      end

      class GZipBufferIO

	def logger
	  HttpStreamingClient.logger
	end

	def initialize(string="")
	  logger.debug "GZipBufferIO:initialize"
	  @packet_stream = string
	end

	def <<(string)
	  @packet_stream << string
	end

	# called by GzipReader
	def readpartial(length=nil, buffer=nil)
	  logger.debug "GZipBufferIO:read:packet_stream:#{@packet_stream.nil? ? 'nil' : 'not nil'}"
	  buffer ||= ""
	  length ||= 0
	  buffer << @packet_stream[0..(length-1)]
	  @packet_stream = @packet_stream[length..-1]
	  buffer
	end
	
	# called by GzipReader
	def read(length=nil, buffer=nil)
	  readpartial(length, buffer)
	end

	# called by GzipReader
	def size
	  @packet_stream.size
	end
      end

      private

      def process_decompressed_packet(decompressed_packet)
	logger.debug "GZipBufferIO:process_decompressed_packet:size:#{decompressed_packet.nil? ? "nil" : decompressed_packet.size}"
	if decompressed_packet && decompressed_packet.size > 0
	  @packet_callback.call(decompressed_packet)
	end
      end

    end
  end

end
