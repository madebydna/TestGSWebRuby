module GS
  module ETL
    module EventLoggable
      def event_log=(event_log)
        @event_log = event_log
      end

      def record(value = 'success', key = event_key)
        row = {
          id: id,
          step: self.class,
          key: key,
          value: value
        }
        @event_log.process(row)
      end

      def event_key
        Hash[instance_variables.map { |name| [name, instance_variable_get(name)] } ].to_s
      end

    end
  end
end
