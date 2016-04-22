require 'logger'

module GS
  module ETL
    module Logging
      class LoggerGroup
        def initialize(*loggers)
          @loggers = loggers
        end
        def log(*args)
          @loggers.each { |logger| logger.log(*args) }
        end
      end

      class StandardLogger
        def self.build_stdout_logger
          new(STDOUT)
        end

        def self.build_file_logger(file)
          f = File.open('foo.log', File::WRONLY | File::APPEND)
          logger = new(f)
          logger
        end

        def initialize(*args)
          l = Logger.new(*args)
          l.formatter = proc do |severity, datetime, progname, msg|
               "#{datetime.strftime("%F %T.%L")} : #{msg}\n"
          end
          @logger = l
        end

        def log(hash)
          message = GS::ETL::Logging.format_one_line(hash)
          @logger.debug(message)
        end
      end

      class AggregatingLogger
        def self.build_stdout_logger
          new(STDOUT)
        end

        def initialize(*args)
          @data = []
          @logger = Logger.new(*args)
        end

        def print_line(line)
          name = line[:name] || ''
          key = line[:key] || ''
          sum = line[:sum] || 0
          average = line[:avg]
          average = average.round(2) if average

          printf(
            "%-70s %-20s %-13s %s",
            name[-66..-1] || name,
            key.to_s[-16..-1] || key,
            "Sum: #{sum}",
            "Avg: #{average}%\n").to_s

        end

        def print_report
          print "\033[1;1H"
          lines.each do |line|
            print_line(line)
          end
        end

        def log(hash)
          id = hash[:id]
          key = hash[:key]
          step = hash[:step]
          value = hash[:value]
          key = "#{step}: #{key}"
          @data[id] ||= {}
          @data[id][key] ||= {}
          @data[id][key][value] ||= 0
          @data[id][key][value] += 1
          print_report
        end

        def lines
          lines = []
          @data.each_with_index do |key_hash, id|
            next unless key_hash

            key_hash.each do |name, key_occurrences|
              executions = key_occurrences[:executed]
              key_occurrences.each_pair do |key, occurrences|
                next if key == :executed
                sum = occurrences
                average = (sum / executions.to_f) * 100
                line = [name, key, sum, average]
                line = {
                  id: id,
                  name: name,
                  key: key,
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

        def formatter

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
