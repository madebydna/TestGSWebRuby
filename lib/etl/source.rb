module GS
  module ETL
    module Source
      def run
        each do |row|
          children.each do |child|
            child.propagate(row) do |child_row, step|
              if child_row.is_a?(Array)
                child_row.map { |r| step.log_and_process(r) }
              else
                step.log_and_process(child_row)
              end
            end
          end
        end
      end
    end
  end
end
