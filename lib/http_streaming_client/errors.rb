module HttpStreamingClient

  class InvalidContentType < Exception; end

  class HttpTimeOut < StandardError; end

  class HttpError < StandardError

    attr_reader :status, :message, :headers

    def initialize(status, message, headers = nil)
      super "#{status}:#{message}"
      @status = status
      @message = message
      @headers = headers
    end
  end

end
