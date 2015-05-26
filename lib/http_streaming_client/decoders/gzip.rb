# encoding: utf-8

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

require "http_streaming_client/errors"

module HttpStreamingClient

  module Decoders

    class GZip

      if defined?(JRUBY_VERSION) then
	# JRuby: pass at least 8k bytes to GzipReader to avoid zlib EOF
        GZIP_READER_MIN_BUF_SIZE = 8192
      else
	# MRI: pass at least 2k bytes to GzipReader to avoid zlib EOF
        GZIP_READER_MIN_BUF_SIZE = 2048
      end

      def logger
	HttpStreamingClient.logger
      end

      def initialize(&packet_callback)
	logger.debug "GZip:initialize"
	@packet_callback = packet_callback
      end

      def <<(compressed_packet)
	return unless compressed_packet && compressed_packet.size > 0
	@buf ||= GZipBufferIO.new
	@buf << compressed_packet
	@gzip ||= Zlib::GzipReader.new @buf

	# pass at least GZIP_READER_MIN_BUF_SIZE bytes to GzipReader to avoid zlib EOF
	while @buf.size > GZIP_READER_MIN_BUF_SIZE do
	  decompressed_packet = nonblock_readline(@gzip)
	  #logger.debug "GZip:<<:decompressed_packet:#{decompressed_packet}"
	  break if decompressed_packet.nil?
	  process_decompressed_packet(decompressed_packet)
	end
      end

      def close
	logger.debug "GZip:close"
	return if @buf.size == 0

	decompressed_packet = ""
	begin
	  @gzip ||= Zlib::GzipReader.new @buf

	  while true do
	    decompressed_packet = nonblock_readline(@gzip, true)
	    logger.debug "GZip:close:decompressed_packet:#{decompressed_packet}"
	    break if decompressed_packet.nil? or decompressed_packet.size == 0
	    process_decompressed_packet(decompressed_packet)
	  end

	rescue Zlib::Error => e
	  raise HttpStreamingClient::DecoderError.new(e.message)
	end
      end
      
      def size
	@buf.size
      end

      def nonblock_readline(io, on_close = false)
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
	rescue Zlib::GzipFile::Error
	  # this is raised on EOF by ZLib in MRI
	  # if we get here via a call to close(), then we want to return the line_buffer
	  # if we get here via any other path, we want to return nil to signal temporary EOF and leave the partial line_buffer contents in place.
	  logger.debug "Gzip:nonblock_readline:Zlib::GzipFile::Error:line_buffer.size:#{@line_buffer.size}"
	  if on_close then
	    result = @line_buffer
	    @line_buffer = ""
	    return result
	  end
	  return nil
	rescue IOError
	  # this is raised on EOF by ZLib in JRuby, return nil to indicate EOF and leave partial line in the buffer
	  # if we get here via a call to close(), then we want to return the line_buffer
	  # if we get here via any other path, we want to return nil to signal temporary EOF and leave the partial line_buffer contents in place.
	  logger.debug "Gzip:nonblock_readline:IOError:line_buffer.size:#{@line_buffer.size}"
	  if on_close then
	    result = @line_buffer
	    @line_buffer = ""
	    return result
	  end
	  return nil
        rescue => e
	  logger.debug "Gzip:nonblock_readline:error received:#{e.class}:#{e}"
	  raise e
	end
	  
	if on_close then
	  result = @line_buffer
	  @line_buffer = ""
	  return result
	end

      end
      
      protected

      class GZipBufferIO < StringIO

	def logger
	  HttpStreamingClient.logger
	end

	def initialize(string="")
	  logger.debug "GZipBufferIO:initialize"
	  @packet_stream = string
	  @packet_stream.force_encoding("BINARY")
	end

	def <<(string)
	  @packet_stream << string
	end

	# called by GzipReader
	def readpartial(length=nil, buffer=nil)
	  logger.debug "GZipBufferIO:readpartial:length:#{length}:@packet_stream:#{@packet_stream.nil? ? 'nil' : @packet_stream.size}"
	  buffer ||= ""

	  raise EOFError "" if @packet_stream.size == 0

	  length ||= @packet_stream.size # read all if a fraction is specified
	  length = [ length, @packet_stream.size ].min # read length or @packet_stream.size, whichever is smaller

	  #logger.debug "GZipBufferIO:readpartial:before:psize:#{@packet_stream.size}:bsize:#{buffer.size}:length:#{length}"

	  buffer << @packet_stream[0..(length-1)]

	  if length == @packet_stream.size then
	    @packet_stream = ""
	    #@packet_stream = @packet_stream.slice!(0,length)
	  else
	    @packet_stream = @packet_stream[length..-1]
	    #@packet_stream = @packet_stream.slice!(0,length)
	  end

	  #logger.debug "GZipBufferIO:readpartial:after:psize:#{@packet_stream.size}:bsize:#{buffer.size}"
	  buffer
	end

	# called by GzipReader
	def read(length=nil, buffer=nil)
	  logger.debug "GZipBufferIO:read:length:#{length}"
	  return nil if @packet_stream.size == 0
	  readpartial(length, buffer)
	end

	# called by GzipReader
	def size
	  logger.debug "GZipBufferIO:size():#{@packet_stream.size}"
	  @packet_stream.size
	end
      end

      private

      def process_decompressed_packet(decompressed_packet)
	logger.debug "GZipBufferIO:process_decompressed_packet:size:#{decompressed_packet.nil? ? "nil" : decompressed_packet.size}"
	if decompressed_packet && decompressed_packet.size > 0
	  @packet_callback.call(decompressed_packet) unless @packet_callback.nil?
	end
      end

    end
  end

end
