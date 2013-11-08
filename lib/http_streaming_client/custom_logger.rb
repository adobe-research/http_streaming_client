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

require 'logger'

module HttpStreamingClient

  class ColoredLogFormatter < Logger::Formatter

    SEVERITY_TO_COLOR_MAP   = {'DEBUG'=>'32', 'INFO'=>'0;37', 'WARN'=>'35', 'ERROR'=>'31', 'FATAL'=>'31', 'UNKNOWN'=>'37'}

    def call(severity, time, progname, msg)
      color = SEVERITY_TO_COLOR_MAP[severity]
      "\033[0;37m[%s] \033[#{color}m%5s - %s\033[0m\n" % [time.to_s, severity, msg]
    end
  end

  class CustomLoggerInternal

    def initialize
      @console = nil
      @logfile = nil
    end

    def method_missing(name, *args)
      if !@console.nil?
	@console.method(name).call(args) unless name.to_s =~ /(unknown|fatal|error|warn|info|debug)/
	@console.method(name).call(args[0])
      end
      @logfile.method(name).call(args[0]) unless @logfile.nil?
    end

    def logfile=(enable)
      return (@logfile = nil) if !enable
      @logfile = Logger.new("test.log")
      @logfile.formatter = ColoredLogFormatter.new
      @logfile.level = Logger::DEBUG
    end

    def console=(enable)
      return (@console = nil) if !enable
      @console = Logger.new(STDOUT)
      @console.formatter = ColoredLogFormatter.new
      @console.level = Logger::INFO
    end

  end

  @custom_logger_internal = nil

  def self.logger
    return @custom_logger_internal unless @custom_logger_internal.nil?
    return @custom_logger_internal = CustomLoggerInternal.new
  end

  def self.logger=(logger)
    @custom_logger_internal = logger
  end
end
