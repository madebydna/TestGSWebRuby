require 'transforms/joiner'
require 'step'

module GS
  module ETL
    module Source
      def run
        each do |row|
          children.each do |child|
            child.inject(row) do |row, step|
              if row.is_a?(Array)
                row.map { |r| step.log_and_process(r) }
              else
                step.log_and_process(row)
              end
            end
          end
        end
      end
    end

    class StepsBuilder
      def initialize(step)
        @step = step
      end

      def add_step(source_class, *args, &block)
        @step = @step.add_step(source_class, *args, &block)
      end
      alias_method :transform, :add_step
      alias_method :destination, :add_step

      def method_missing(method, *args, &block)
        @step.send(method, *args, &block)
      end
    end

    class DataProcessor
      def source(source_class, *args)
        source = source_class.new(*args)
        source.event_log = event_log if source.respond_to?('event_log=')
        StepsBuilder.new(source)
      end

      def event_log
        @event_log ||= EventLog.new
      end
    end

  end
end

class RunOtherStep < GS::ETL::Step
  def initialize(step)
    @step = step
  end

  def process(row)
    @step.run
    row
  end
end
