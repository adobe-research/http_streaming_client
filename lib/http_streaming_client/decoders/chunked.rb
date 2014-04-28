###########################################################################
##
## http_streaming_client
##
## Ruby HTTP client with support for HTTP 1.1 streaming, GZIP compressed
## streams, and chunked transfer encoding. Includes extensible OAuth
## support for the Adobe Analytics Firehose and Twitter Streaming APIs.
##
## David Tompkins -- 4/25/2014
## tompkins@adobe_dot_com
##
###########################################################################
##
## Copyright (c) 2014 Adobe Systems Incorporated. All rights reserved.
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

require "http_streaming_client/errors"

module HttpStreamingClient

  module Decoders

    class Chunked

      def logger
	HttpStreamingClient.logger
      end

      def initialize(&packet_callback)
	logger.debug "Chunked:initialize"
	@packet_callback = packet_callback
      end

      def <<(chunk)
	return unless chunk && chunk.size > 0
	chunk_io = StringIO.new(chunk)
	while true
	  line = nonblock_readline(chunk_io)
	  break if line.nil?
	  process_line(line)
	end
      end

      def size
	logger.debug "Chunked:size"
	return @line_buffer.size unless @line_buffer.nil?
	return 0
      end

      def close
	logger.debug "Chunked:close"
      end

      protected

      def nonblock_readline(io)
	@line_buffer ||= ""
	ch = nil
	begin
	  while ch = io.getc
	    @line_buffer += ch
	    if ch == "\n" then
	      result = @line_buffer
	      @line_buffer = ""
	      return result
	    end
	  end
	rescue => e
	  logger.debug "nonblock_readline:error received:#{e.class}:#{e}"
	  return nil
	end
      end

      private

      def process_line(line)
	logger.debug "Chunked:process_line:size:#{line.nil? ? "nil" : line.size}"
	if line && line.size > 0
	  @packet_callback.call(line) unless @packet_callback.nil?
	end
      end

    end
  end
end
