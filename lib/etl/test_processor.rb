require_relative './file_logger'
require_relative '../states' # FIXME: This require is outside the etl directory

require_all = ->(dir) do
  dir_relative_to_this_file = File.dirname(__FILE__)
  glob = File.join(dir_relative_to_this_file, dir, '*.rb')
  Dir[glob].each { |file| require file }
end

require_all.call 'transforms'
require_all.call 'sources'
require_all.call 'destinations'

module GS
  module ETL
    class TestProcessor
      attr_reader :runnable_steps, :attachable_input_step, :attachable_output_step
      attr_writer :source_columns

      FILE_LOCATION = '/tmp/'
      SCHOOL_TYPE_STRING = 'public.charter'
      ENTITIES = ['school', 'state', 'district']
      COLUMN_ORDER = [ :year, :entity_type, :entity_level, :state_id, :school_id, :school_name,
                       :district_id, :district_name, :test_data_type, :test_data_type_id, :grade,
                       :subject, :subject_id, :breakdown, :breakdown_id, :proficiency_band,
                       :proficiency_band_id, :level_code, :number_tested, :value_float]

      def initialize(input_dir, options = {})
        @input_dir = input_dir
        @options = options
        @runnable_steps = []
      end

      def source_columns
        @source_columns ||= []
      end

      def input_filename(name_or_regex)
        if name_or_regex.is_a? Regexp
          Dir.entries(@input_dir).map { |entry| input_filename(file) }
            .select { |abs_path| File.file? abs_path && name_or_regex =~ file }
        else
          File.join(@input_dir, name_or_regex)
        end
      end

      def source(source_class, *args)
        source = source_class.new(*args)
        source.event_log = event_log if source.respond_to?('event_log=')
        StepsBuilder.new(source)
      end

      def event_log
        # @event_log ||= EventLog.new
        # @event_log ||= FileLogger.new File.join(FILE_LOCATION, "#{self.class.name}.log")
      end

      def output_files_step_tree
        self.class.define_output_files
        build_file_output_steps
        output_files_root_step
      end

      def config_step
        @config_step ||= LoadConfigFile.new config_output_file, config_hash
      end

      class << self
        attr_writer :shared_block

        def source(*args, &block)
          source_class = if args[0].is_a? Class and args[0] < GS::ETL::Source
                           args.shift
                         else
                           CsvSource
                         end
          source_step = source_class.new(*args)
          block = block_given? ? block : proc { |s| s }
          source_pairs << [source_step, block]
          source_step
        end

        def shared(&block)
          @shared_block = block
        end

        def xsource(*args, &block)
          puts "ignoring source #{args.map(&:inspect).join(' ')}"
        end

        def source_pairs
          @source_pairs ||= []
        end

        def shared_block
          @shared_block ||= Proc.new { |s| s }
        end
      end

      def build_column_value_report
        require_relative 'column_value_report'
        ::ColumnValueReport.new('column_value_report.txt', :grade, :breakdown_id)
      end

      def build_graph
        require_relative 'column_value_report'
        source_pairs = self.class.source_pairs
        @sources = source_pairs.map { |pair| pair[0] }
        source_leaves = source_pairs.map do |source, block|
          instance_exec(source, &block)
        end
        shared_root = Step.new
        shared_block = self.class.shared_block
        shared_leaf = instance_exec(shared_root, &shared_block)
        union_steps(*source_leaves).add(shared_root)
        shared_leaf.add(output_files_step_tree)
        column_value_report = build_column_value_report
        shared_leaf.add(column_value_report.build_graph)
        @runnable_steps += column_value_report.runnable_steps
        shared_leaf.transform("Adds data_type_id column for config file", WithBlock) do |row|
         row[:data_type_id] = row[:test_data_type_id]
         row
        end.add(config_step)
      end

      def context_for_sources
        {dir: @input_dir, max: @options[:max]}
      end

      def run
        build_graph
        @sources.each do |source|
          source.run(context_for_sources)
        end
        config_step.run
        @runnable_steps.each do |step|
          step.run
        end
      end

      private

      def build_file_output_steps
        school_steps
        state_steps
        district_steps
        # unique_breakdown_mappings
      end

      def output_files_root_step
        @_output_files_root_step ||= (
          s = Step.new
          s.description = 'Root for output files subgraph'
          s
        )
      end

      def self.define_output_files
        ENTITIES.each do |entity|
          define_method("#{entity}_output_file".to_sym) do
            FILE_LOCATION +  data_file_prefix + entity + ".txt"
          end
        end
      end

      def state_steps
        node = output_files_root_step.add_step('Keep only state rows', KeepRows, :entity_level, 'state')
        node = node.transform 'Fill a bunch of columns with "state"', WithBlock do |row|
          row[:state_id] = 'state'
          row[:school_id] = 'state'
          row[:school_name] = 'state'
          row[:district_name] ='state'
          row[:district_id] = 'state'
          row
        end
        node.destination 'Output state rows to CSV', CsvDestination,
          send("state_output_file".to_sym),
          *COLUMN_ORDER
        node
      end

      def district_steps
        node = output_files_root_step.add_step(
          'Keep only district rows',
          KeepRows,
          :entity_level, 'district'
        )
        node = node.transform 'Fill a couple columns with "district"', Fill,
          school_id: 'district',
          school_name: 'district'

        node.destination 'Output district rows to CSV',
          CsvDestination,
          send("district_output_file".to_sym),
          *COLUMN_ORDER

        node
      end

      def school_steps
        node = output_files_root_step.add_step('Keep only school rows', KeepRows, :entity_level, 'school')
        node.destination 'Output school rows to CSV', CsvDestination,
          send("school_output_file".to_sym),
          *COLUMN_ORDER
        node
      end

      def config_hash
        #  If config hash is NOT defined by transform script should raise error
        raise ArgumentError
      end

      def data_file_prefix
        [state, @year, 1, SCHOOL_TYPE_STRING].join('.') + '.'
      end

      def state
        @_state ||=(
          state = self.class.to_s.slice(0..1).downcase
          raise StandardError unless States.abbreviations.include?(state)
          state
        )
      end

      def config_output_file
        FILE_LOCATION + ['config', state,  @year ,'test.1.txt'].join('.')
      end

      def tab_delimited_source(file_array_or_str)
        filenames = *file_array_or_str
        paths = filenames.map { |fn| input_filename fn }
        #TODO: shouldn't need to check for existence of options
        max = (@options && @options[:max])
        source = CsvSource.new(paths, source_columns, col_sep: "\t", max: max)
        source.description = filenames.map { |f| f.split('/').last }.join("\n")
        source.event_log = self.event_log
        source
      end

      def union_steps(*steps)
        step = Step.new
        step.event_log = self.event_log
        step.description = "Union steps:\n" + steps.map(&:description).join("\n")
        steps.each { |s| s.add(step) }
        step
      end

      def attach_to_step(graph, step)
        unless graph.attachable_input_step
          raise 'Illegal state: graph has no input step to attach'
        end
        step.add(graph.attachable_input_step)
        @runnable_steps += graph.runnable_steps
        @attachable_output_step = graph.attachable_output_step
      end

      def attach(graph)
        unless self.attachable_output_step
          raise 'Illegal state: no output step to attach graph to'
        end
        attach_to_step(graph, self.attachable_output_step)
      end

    end
  end
end
