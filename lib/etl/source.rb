require_relative 'step'
# require 'enumerable'

module GS
  module ETL
    class Source < GS::ETL::Step
      include Enumerable

      def run(context={})
        propagated_action = Proc.new do |step, rows|
          if rows.is_a?(Array)
            rows.map { |r| step.log_and_process(r) }
          else
            step.log_and_process(rows)
          end
        end

        run_proc = Proc.new do |row|
          children.each do |child|
            child.propagate(row, &propagated_action)
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
