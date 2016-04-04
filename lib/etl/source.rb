module GS
  module ETL
    module Source
      def run
        each do |row|
          propagate(row) do |step, rows|
            if rows.is_a?(Array)
              rows.map { |r| step.log_and_process(r) }
            else
              step.log_and_process(rows)
            end
          end
        end
      end
    end
  end
end
