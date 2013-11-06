require 'socket'
require 'uri'
require 'zlib'

require "http_streaming_client/version"
require "http_streaming_client/custom_logger"
require "http_streaming_client/errors"
require "http_streaming_client/decoders/gzip"

module HttpStreamingClient

  class Client

    attr_accessor :socket, :interrupted, :compression_requested

    ALLOWED_MIME_TYPES = ["application/json", "text/plain", "text/html"]

    def initialize(opts = {})
      @socket = nil
      @interrupted = false
      @compression_requested = opts[:compression_requested] ? opts[:compression_requested] : true
    end

    def self.logger
      HttpStreamingClient.logger
    end

    def self.get(uri, opts = {}, &block)
      logger.debug("get:#{uri}")
      request("GET", uri, opts, &block)
    end

    def get(uri, opts = {}, &block)
      logger.debug("get(interrupt):#{uri}")
      @interrupted = false
      begin
	request("GET", uri, opts, &block)
      rescue IOError => e
	raise e unless @interrupted
      end
    end

    def self.post(uri, body, opts = {}, &block)
      logger.debug("post:#{uri}")
      request("POST", uri, opts.merge({:body => body}), &block)
    end

    def post(uri, body, opts = {}, &block)
      logger.debug("post(interrupt):#{uri}")
      @interrupted = false
      begin
	request("POST", uri, opts.merge({:body => body}), &block)
      rescue IOError => e
	raise e unless @interrupted
      end
    end

    def interrupt
      logger.debug("interrupt")
      @interrupted = true
      @socket.close
    end

    protected

    def self.request(method, uri, opts = {}, &block)
      logger.debug("Client::request:#{method}:#{uri}")

      if uri.is_a?(String)
	uri = URI.parse(uri)
      end

      default_headers = {
	"User-Agent" => opts["User-Agent"] || "HttpStreamingClient #{HttpStreamingClient::VERSION}",
	"Accept" => "*/*",
	"Accept-Charset" => "utf-8"
      }

      if method == "POST" || method == "PUT"
	default_headers["Content-Type"] = opts["Content-Type"] || "application/x-www-form-urlencoded;charset=UTF-8"
	body = opts.delete(:body)
	if body.is_a?(Hash)
	  body = body.keys.collect {|param| "#{URI.escape(param.to_s)}=#{URI.escape(body[param].to_s)}"}.join('&')
	end
	default_headers["Content-Length"] = body.length
      end

      unless uri.userinfo.nil?
	default_headers["Authorization"] = "Basic #{[uri.userinfo].pack('m').strip!}\r\n"
      end

      encodings = []
      encodings << "gzip" if @compression_requested or opts[:compression_requested]
      if encodings.any?
	default_headers["Accept-Encoding"] = "#{encodings.join(',')}"
      end

      headers = default_headers.merge(opts[:headers] || {})
      logger.debug "request headers: #{headers}"

      socket = initialize_socket(uri, opts)
      request = "#{method} #{uri.path}#{uri.query ? "?"+uri.query : nil} HTTP/1.1\r\n"
      request << "Host: #{uri.host}\r\n"
      headers.each do |k, v|
	request << "#{k}: #{v}\r\n"
      end
      request << "\r\n"
      if method == "POST"
	request << body
      end

      socket.write(request)

      response_head = {}
      response_head[:headers] = {}

      socket.each_line do |line|
	if line == "\r\n" then
	  break
	else
	  header = line.split(": ")
	  if header.size == 1
	    header = header[0].split(" ")
	    response_head[:version] = header[0]
	    response_head[:code] = header[1].to_i
	    response_head[:msg] = header[2]
	    logger.debug "HTTP response code is #{response_head[:code]}"
	  else
	    response_head[:headers][camelize_header_name(header[0])] = header[1].strip
	  end
	end
      end

      logger.debug "response headers:#{response_head[:headers]}"

      content_length = response_head[:headers]["Content-Length"].to_i
      logger.debug "content-length: #{content_length}"

      content_type = response_head[:headers]["Content-Type"].split(';').first
      logger.debug "content-type: #{content_type}"

      response_compression = false

      if ALLOWED_MIME_TYPES.include?(content_type)
	case response_head[:headers]["Content-Encoding"]
	when "gzip"
	  response_compression = true
	end
      else
	raise InvalidContentType, "invalid response MIME type: #{content_type}"
      end

      if (response_head[:code] != 200)
	s = "Received HTTP #{response_head[:code]} response"
	logger.debug "request: #{request}"
	response = socket.read(content_length)
	logger.debug "response: #{response}"
	raise HttpError.new(response_head[:code], "Received HTTP #{response_head[:code]} response", response_head[:headers])
      end

      if response_head[:headers]["Transfer-Encoding"] == 'chunked'
	partial = nil
	decoder = nil
	response = ""
	if response_compression then
	  logger.debug "response compression detected"
	  if block_given? then
	    decoder = HttpStreamingClient::Decoders::GZip.new { |line|
	      logger.debug "read #{line.size} uncompressed bytes"
	      block.call(line) unless @interrupted }
	  else
	    decoder = HttpStreamingClient::Decoders::GZip.new { |line|
	      logger.debug "read #{line.size} uncompressed bytes, #{response.size} bytes total"
	      response << line unless @interrupted }
	  end
	end

	while !socket.eof? && (line = socket.gets)
	  chunkLeft = 0
	  break if line.match /^0.*?\r\n/
	    next if line == "\r\n"
	  size = line.hex
	  logger.debug "chunk size:#{size}"

	  partial = socket.read(size)
	  next if partial.nil?

	  remaining = size-partial.size
	  logger.debug "read #{partial.size} bytes, #{remaining} bytes remaining"
	  until remaining == 0
	    partial << socket.read(remaining)
	    remaining = size-partial.size
	    logger.debug "read #{partial.size} bytes, #{remaining} bytes remaining"
	  end

	  return if @interrupted

	  if response_compression then
	    if block_given? then
	      decoder << partial
	    else
	      response << partial
	    end
	  else
	    if block_given? then
	      yield partial
	    else
	      logger.debug "no block specified, returning chunk results and halting streaming response"
	      return partial
	    end
	  end
	end

	return partial # returning the last chunk as the return value, handles single chunk chunked responses (thanks, google) without a block handler

      else
	# Not chunked transfer encoding, but potentially gzip'd, and potentially streaming with content-length = 0

	if content_length > 0 then
	  bits = socket.read(content_length)
	  logger.debug "read #{content_length} bytes"
	  return bits if !response_compression
	  logger.debug "response compression detected"
	  begin
	    decoder = Zlib::GzipReader.new(StringIO.new(bits))
	    return decoder.read
	  rescue Zlib::Error
	    raise DecoderError
	  end
	end

	if response_compression then

	  logger.debug "response compression detected"
	  decoder = nil
	  response = ""

	  if block_given? then
	    decoder = HttpStreamingClient::Decoders::GZip.new { |line|
	      logger.debug "read #{line.size} uncompressed bytes"
	      block.call(line) unless @interrupted }
	  else
	    decoder = HttpStreamingClient::Decoders::GZip.new { |line|
	      logger.debug "read #{line.size} uncompressed bytes, #{response.size} bytes total"
	      response << line unless @interrupted }
	  end

	  while (!socket.eof? and !(line = socket.read_nonblock(2048)).nil?)
	    logger.debug "read compressed line, #{line.size} bytes"
	    decoder << line
	    break response if @interrupted
	  end
	  logger.debug "EOF detected"
	  decoder = nil

	  return response

	else

	  response = ""

	  while (!socket.eof? and !(line = socket.readline).nil?)
	    if block_given? then
	      yield line
	      logger.debug "read #{line.size} bytes"
	    else
	      logger.debug "read #{line.size} bytes, #{response.size} bytes total"
	      response << line
	    end
	    break if @interrupted
	  end

	  return response

	end

      end
    ensure
      socket.close if !socket.nil? and !socket.closed?
    end

    private

    def self.camelize_header_name(header_name)
      (header_name.split('-').map {|s| s.capitalize}).join('-')
    end

    def self.initialize_socket(uri, opts = {})
      return opts[:socket] if opts[:socket]

      if uri.is_a?(String)
	uri = URI.parse(uri)
      end

      @socket = TCPSocket.new(uri.host, uri.port)

      if uri.scheme.eql? "https"
	ctx = OpenSSL::SSL::SSLContext.new
	ctx.set_params(verify_mode: OpenSSL::SSL::VERIFY_PEER)
	@socket = OpenSSL::SSL::SSLSocket.new(@socket, ctx).tap do |socket|
	  socket.sync_close = true
	  socket.connect
	end
      end

      opts.merge!({:socket => @socket})
      @interrupted = false
      return opts[:socket]
    end
  end

end
