require_relative 'step'

module GS
  module ETL
    class Source < GS::ETL::Step

      def run(context={})
        run_proc = Proc.new do |row|
          propagate(row) do |step, rows|
            if rows.is_a?(Array)
              rows.flatten.map { |r| step.log_and_process(r) }.flatten
            else
              step.log_and_process(rows)
            end
          end
        end

        if method(:each).arity != 0
          each(context, &run_proc)
        else
          each(&run_proc)
        end
      end
    end
  end
end
