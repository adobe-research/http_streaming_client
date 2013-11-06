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

    @console = nil
    @logfile = nil

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
      @console = defined?(Rails) ? Rails.logger : Logger.new(STDOUT)
      @console.formatter = ColoredLogFormatter.new
      @console.level = Logger::INFO
    end

  end

  @@custom_logger_internal = nil

  def logger
    return @@custom_logger_internal unless @@custom_logger_internal.nil?
    return @@custom_logger_internal = CustomLoggerInternal.new
  end

  def self.logger
    return @@custom_logger_internal unless @@custom_logger_internal.nil?
    return @@custom_logger_internal = CustomLoggerInternal.new
  end

end
