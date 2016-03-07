module GS
  module ETL
    class Step
      attr_accessor :id, :event_log

      def run(row)
        record(:executed) if event_log
        process(row)
      end

      def id
        @id || 0
      end

      def record(value = 'success', key = event_key)
        row = {
          id: id,
          step: self.class,
          key: key,
          value: value
        }
        event_log.process(row)
      end

      def event_key
        Hash[instance_variables.map { |name| [name, instance_variable_get(name)] } ].to_s
      end

    end
  end
end
