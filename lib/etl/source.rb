require_relative 'step'
require_relative 'row'

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

      def input_files=(input_files)
        raise ArgumentError, 'input_files must not be nil' unless input_files
        unless input_files.is_a?(Array)
          raise ArgumentError, 'input_files must be an array'
        end
        if input_files.length < 1
          raise ArgumentError, 'Must provide at least one input file'
        end
        @input_files = input_files
      end

      protected

      def max
        @_max ||= @options.delete(:max)
      end

      def input_files(dir = nil)
        if dir
          @input_files.map { |f| filename_with_dir(f, dir) }.flatten
        else
          @input_files
        end
      end

      def columns=(columns)
        @columns = columns
      end

      def filename_with_dir(name_or_regex, dir)
        if name_or_regex.is_a? Regexp
          Dir.entries(dir).map { |entry| input_filename(file) }
            .select { |abs_path| File.file? abs_path && name_or_regex =~ file }
        else
          File.join(dir, name_or_regex)
        end
      end

    end
  end
end
