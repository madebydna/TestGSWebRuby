require 'transforms/joiner'
require 'event_log'

module GS
  module ETL
    
    class StepNode
      attr_accessor :step, :parent, :children

      def initialize(step = nil)
        @children = []
        @step = step
        @parent = nil
      end

      def run(row)
        return if row.nil?
        rows = @step.run(row) if @step
        rows ||= row
        rows = [rows] unless rows.is_a?(Array)
        @children.each do |step|
          rows.each { |r| step.run(r.dup) }
        end
        rows
      end

      def add(step)
        @children << step
        step.parent = self
        self
      end
    end

    # class DataSteps
    #   def initialize(source, step_tree)
    #     @source = source
    #     @step_tree = step_tree
    #   end
    # end


    class DataSteps
      attr_accessor :event_log

      def initialize(source, root_step)
        @source = source
        @root_step = root_step
        @last_step = @root_step
        @step_count = 0
      end

      def add_step(step_class, *args)
        step = build_step(step_class, *args)
        step_node = StepNode.new(step)
        step.id = @step_count+=1
        @last_step.add(step_node)
        @last_step = step_node
      end

      def build_step(step_class, *args)
        step = step_class.new(*args)
        step.event_log = @event_log if step.respond_to?('event_log=')
        step
      end

      alias_method :transform, :add_step
      alias_method :destination, :add_step

      def add_steps(array_of_arrays)
        array_of_arrays.map do |step_definition_array|
          step_class = step_definition_array.shift
          add_step(step_class, step_definition_array)
        end
      end

      def fork(step_class, *args)
        step = add_step(step_class, *args)
        step = step.parent if step.parent
        step
      end

      def join(data_steps_2, *args)
        rows = data_steps_2.buffer
        self.add_step(Joiner, rows, *args)
      end

      def run
        # system('clear')
        @source.each do |row|
          @root_step.run(row)
        end
      end

      def buffer
        rows = []
        @source.each do |row|
          rows += @root_step.run(row)
        end
        rows
      end
    end

    class DataProcessor
      def source(source_class, *args)
        source_with_step_tree = DataSteps.new(data_source(source_class, *args), StepNode.new)
        source_with_step_tree.event_log = event_log
        source_with_step_tree
      end

      def data_source(source_class, *args)
        @_data_source ||= (
          source = source_class.new(*args)
          source.event_log = event_log if source.respond_to?('event_log=')
          source
        )
      end

      def event_log_steps
        @event_log_steps ||= (
          DataSteps.new(event_log, StepNode.new)
        )
      end

      def event_log
        @event_log ||= (
          EventLog.new
        )
      end
    end

  end
end


    class RunOtherStepTree < GS::ETL::Step
      def initialize(data_steps)
        @data_steps = data_steps
      end

      def run(row)
        @data_steps.run
      end
    end
