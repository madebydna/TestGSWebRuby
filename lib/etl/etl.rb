require 'transforms/joiner'

module GS
  module ETL
    
    class StepNode
      attr_accessor :step, :parent, :children

      def initialize(step = nil)
        @children = []
        @step = step
        @parent = nil
      end

      def process(row)
        return if row.nil?
        rows = @step.process(row) if @step
        rows ||= row
        rows = [rows] unless rows.is_a?(Array)
        @children.each do |step|
          rows.each { |r| step.process(r.dup) }
        end
        rows
      end

      def add(step)
        @children << step
        step.parent = self
        self
      end
    end


    class DataSteps
      def initialize(source, root_step)
        @source = source
        @root_step = root_step
        @last_step = @root_step
      end

      def add_step(step_class, *args)
        step = build_step(step_class, *args)
        step_node = StepNode.new(step)
        @last_step.add(step_node)
        @last_step = step_node
      end

      def build_step(step_class, *args)
        step_class.new(*args)
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
        @source.each do |row|
          @root_step.process(row)
        end
      end

      def buffer
        rows = []
        @source.each do |row|
          rows += @root_step.process(row)
        end
        rows
      end
    end

    module DataStepsMachine
      def source(source_class, *args)
        source = source_class.new(*args)
        tree = StepNode.new
        source_with_step_tree = DataSteps.new(source, tree)
        source_with_step_tree
      end
    end

  end
end


