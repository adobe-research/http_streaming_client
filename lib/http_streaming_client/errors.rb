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

module HttpStreamingClient

  class InvalidContentType < Exception; end
  
  class InvalidRedirect < Exception; end
  
  class ReconnectRequest < StandardError; end

  class HttpTimeOut < StandardError; end
  
  class DecoderError < StandardError; end

  class HttpError < StandardError

    attr_reader :status, :message, :headers, :response

    def initialize(status, message, headers = nil, response = nil)
      super "#{status}:#{message}:#{headers}:#{response}"
      @status = status
      @message = message
      @headers = headers
      @response = response
    end
  end

end
