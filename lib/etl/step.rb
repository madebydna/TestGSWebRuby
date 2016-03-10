module GS
  module ETL
    class Step
      attr_accessor :parent, :children, :id, :event_log

      def add_step(step_class, *args)
        step = step_class.new(*args)
        step.id = id+1
        add(step)
        step
      end
      alias_method :transform, :add_step
      alias_method :destination, :add_step

      def fork(step_class, *args)
        step = add_step(step_class, *args)
        step.parent ? step.parent : step
      end

      def root
        parent.nil? ? self : parent.root
      end

      def log_and_process(row)
        return unless row
        record(:executed) if self.event_log
        process(row)
      end

      def inject(start_value, &block)
        result = block.call(start_value, self)
        children.each do |child|
          result = result.clone if result
          child.inject(result, &block)
        end
      end

      def process(row)
        # Do nothing for base step
        row
      end

      def id
        @id || 0
      end

      def children
        @children ||= []
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
        step.parent = self
        self
      end
    end

  end
end
