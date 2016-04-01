module GS
  module ETL
    class Step
      attr_accessor :parents, :children, :id, :event_log, :description

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
        record(:executed) if self.event_log
        process(row)
      end

      def propagate(start_value, &block)
        result = block.call(start_value, self)
        children.each do |child|
          r = result ? result.clone : nil
          child.propagate(r, &block)
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
        self.class.name + id.to_s
      end

      def children
        @children ||= []
      end

      def parents
        @parents ||= []
      end

      def record(value = 'success', key = event_key)
        row = {
          id: id,
          step: self.class,
          key: key,
          value: value
        }
        event_log.process(row) if event_log
      end

      def event_key
        "Implement #event_key on #{self.class}"
      end

      def add(step)
        step.event_log = event_log if step.respond_to?('event_log=')
        self.children << step
        step.parents << self
        self
      end
    end

  end
end
