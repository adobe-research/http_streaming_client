module HttpStreamingClient
  require 'http_streaming_client/version'
  require 'http_streaming_client/client'
  require 'http_streaming_client/custom_logger'
  require 'http_streaming_client/oauth'
  require 'http_streaming_client/railtie' if defined?(Rails)
end
