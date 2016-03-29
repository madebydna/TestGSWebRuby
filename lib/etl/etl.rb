require 'transforms/joiner'
require 'step'
require_relative '../states'

module GS
  module ETL
    class StepsBuilder
      attr_accessor :step
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
