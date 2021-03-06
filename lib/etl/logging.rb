require 'logger'

module GS
  module ETL
    module Logging
      class Logger
        def disabled?
          ::GS::ETL::Logging.disabled?
        end

        def one_row?
          ::GS::ETL::Logging.one_row?
        end

        def error(*args)
          @logger.error(*args)
        end

        def finish
          # noop by default
        end
      end
      
      class LoggerGroup < Logger
        def initialize(*loggers)
          @loggers = loggers
        end
        def log_event(*args)
          @loggers.each { |logger| logger.log_event(*args) }
        end
      end

      class StandardLogger < Logger
        def self.build_stdout_logger
          new(STDOUT)
        end

        def self.build_file_logger(file)
          f = File.open(file, File::WRONLY | File::APPEND)
          logger = new(f)
          logger
        end

        def initialize(*args)
          l = ::Logger.new(*args)
          l.formatter = proc do |severity, datetime, progname, msg|
               "#{datetime.strftime("%F %T.%L")} : #{msg}\n"
          end
          @logger = l
        end

        def log_event(hash)
          return if disabled?
          message = GS::ETL::Logging.format_one_line(hash)
          @logger.debug(message)
        end
      end

      class AggregatingLogger < Logger
        def self.build_stdout_logger
          new(STDOUT)
        end

        def initialize(*args)
          @data = {}
          @logger = ::Logger.new(*args)
        end

        def print_line(line)
          description = line[:description] || ''
          key = line[:key] || ''
          value = line[:value] || ''
          sum = line[:sum] || 0
          average = line[:avg]
          average = average.round(2) if average

          printf(
            "%-100s %-20s %-11s %s",
            # description[-50..-1] || description,
            key.to_s[-100..-1] || key,
            value.to_s[-20..-1] || value,
            "Sum: #{sum}",
            "Avg: #{average}%\n").to_s
        end

        def print_report
          print "\033[1;1H"
          lines.each do |line|
            print_line(line)
          end
        end

        def log_event(hash)
          return if disabled?
          id = hash[:descriptor]
          key = hash[:key]
          step = hash[:step]
          value = hash[:value]
          key = "#{step}: #{key}"
          @data[id] ||= {}
          @data[id][key] ||= {}
          @data[id][key][value] ||= 0
          @data[id][key][value] += 1
          # print_report
        end

        def finish
          print_report
        end

        def lines
          lines = []
          @data.each_pair do |description, key_hash|
            next unless key_hash

            key_hash.each do |key, key_occurrences|
              executions = key_occurrences[:executed]
              key_occurrences.each_pair do |value, occurrences|
                next if value == :executed
                sum = occurrences
                average = (sum / executions.to_f) * 100
                line = {
                  description: description,
                  key: key,
                  value: value,
                  sum: sum,
                  avg: average
                }
                lines << line
              end
            end

          end
          return lines
        end
      end
      
      class << self
        def logger
          @logger ||= GS::ETL::Logging::StandardLogger.build_stdout_logger
        end

        def disabled?
          !!@disabled
        end

        def one_row?
          !!@one_row
        end
        
        def disable
          @disabled = true
        end

        def enable
          @disabled = false
        end

        def one_row
          enable
          @one_row = true
        end

        def all_rows
          enable
          @one_row = false
        end

        def logger=(logger)
          @logger = logger
        end

        def format_one_line(hash)
          message_tokens = []
          message_tokens << "Step %3s" % hash[:id]
          message_tokens << "row %5s" % hash[:row_num] || '?'
          message_tokens << "clone %3s" % hash[:clone_num] || 0
          message_tokens << hash[:descriptor][0..30]
          message_tokens << "event: #{hash[:key]}"[0..30]
          message_tokens << "message: #{hash[:value]}"[0..30]
          message_tokens.join(' | ')
        end
      end

      def self.included(base)
        class << base
          def logger
            Logging.logger
          end
        end
      end

      def logger
        Logging.logger
      end
    end

  end
end
