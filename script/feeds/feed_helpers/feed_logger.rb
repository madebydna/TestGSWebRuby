require 'logger'

module Feeds
  LOG_LOCATION = ENV_GLOBAL['feed_log_location'].present? ? ENV_GLOBAL['feed_log_location'] : 'feeds_log.txt'
  FEED_LOG_LEVEL = ENV_GLOBAL['feed_log_level'].present? ? ENV_GLOBAL['feed_log_level'] : Logger::DEBUG

  class FeedLog
    def self.log
      if @feeds_logger.nil?
                @feeds_logger = Logger.new(LOG_LOCATION)
                @feeds_logger.level = FEED_LOG_LEVEL
                @feeds_logger.datetime_format = '%Y-%m-%d %H:%M:%S '
                @feeds_logger.formatter = formatter
      end
        @feeds_logger
    end

    def self.formatter
      proc do |severity, datetime, progname, msg|
        date_format = datetime.strftime("%Y-%m-%d %H:%M:%S")
        # Adding caller let you know which method the log was being called from details http://alisnic.github.io/posts/ruby-logs/
        if  (severity == 'ERROR' || severity == 'FATAL')
          # Adding Stack trace for error and fatal exceptions
          "[#{date_format}] #{severity.ljust(5)}  (#{caller[4]}}): #{msg}\n Backtrace:\n\t#{msg.try(:backtrace).try(:join, "\n\t")}\n"
        else
          "[#{date_format}] #{severity.ljust(5)}  : #{msg}\n"
        end
      end
    end

  end
end