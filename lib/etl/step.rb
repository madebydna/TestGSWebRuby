require 'logger'
require_relative './logging'

module GS
  module ETL
    class Step
      include GS::ETL::Logging

      attr_accessor :parents, :children, :id, :description

      def add_step(description, step_class, *args, &block)
        step = step_class.new(*args, &block)
        step.description = description
        step.id = id+1
        add(step)
        step
      end

      alias_method :transform, :add_step
      alias_method :destination, :add_step

      def log_and_process(row)
        return unless row
        record(row, :executed)
        process(row)
      end

      def propagate(result_from_parent, &block)
        *results = block.call(self, result_from_parent)
        clones = results
        children.each do |child|
          if children.count > 1
            clones = results.map { |row| row && row.clone }
          end
          child.propagate(clones, &block)
        end
      end

      def to_a
        [self] + children.inject([]) { |array, child| array += child.to_a }
      end

      def each_edge(&block)
        children.each do |child|
          block.call(self, child)
          child.each_edge(&block)
        end
      end

      def process(row)
        # Do nothing for base step
        row
      end

      def id
        @id || 0
      end

      def descriptor
        if self.description
          self.class.name + ' ' + self.description 
        else
          self.class.name
        end
      end

      def children
        @children ||= []
      end

      def parents
        @parents ||= []
      end

      def record(row, value = 'success', key = event_key)
        row_num = row && row.respond_to?(:row_num) ? row.row_num : nil
        clone_num = row && row.respond_to?(:clone_num) ? row.clone_num : nil
        event = {
          id: id,
          step: self.class,
          key: key,
          value: value,
          descriptor: descriptor,
          row_num: row_num,
          clone_num: clone_num
        }
        logger.log(event)
      end

      def event_key
        "Implement #event_key on #{self.class}"
      end

      def add(step)
        self.children << step
        step.parents << self
        self
      end

      def px()
        add_step('print row', WithBlock) { |row| puts row.inspect }
      end

      def pp()
        add_step('print and pass row', WithBlock) { |row| p row }
      end

    end
  end
end
