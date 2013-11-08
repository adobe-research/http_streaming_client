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

    class Base

      def initialize(&chunk_callback)
	@chunk_callback = chunk_callback
      end

      def <<(compressed)
	return unless compressed && compressed.size > 0
	decompressed = decompress(compressed)
	receive_decompressed decompressed
      end

      def finalize!
	decompressed = finalize
	receive_decompressed decompressed
      end

      private

      def receive_decompressed(decompressed)
	if decompressed && decompressed.size > 0
	  @chunk_callback.call(decompressed)
	end
      end

      protected

      # Must return a part of decompressed
      def decompress(compressed)
	nil
      end

      # May return last part
      def finalize
	nil
      end
    end

    class GZip < Base

      def decompress(compressed)
	@buf ||= StringIO.new
	@buf << compressed

	# Zlib::GzipReader loads input in 2kbyte chunks
	if @buf.size > 2048
	  @gzip ||= Zlib::GzipReader.new @buf
	  @gzip.readline
	end
      end

      def finalize
	begin
	  @gzip ||= Zlib::GzipReader.new @buf
	  @gzip.read
	rescue Zlib::Error
	  raise DecoderError
	end
      end

      class StringIO
	def initialize(string="")
	  @stream = string
	end

	def <<(string)
	  @stream << string
	end

	def read(length=nil, buffer=nil)
	  buffer ||= ""
	  length ||= 0
	  buffer << @stream[0..(length-1)]
	  @stream = @stream[length..-1]
	  buffer
	end

	def size
	  @stream.size
	end
      end
    end

  end

end
