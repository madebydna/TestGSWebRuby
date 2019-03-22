require_relative './file_logger'
require_relative '../states' # FIXME: This require is outside the etl directory
require_relative './logging'
require_relative './row'
require_relative './gs_ids_fetcher'

require_all = ->(dir) do
  dir_relative_to_this_file = File.dirname(__FILE__)
  glob = File.join(dir_relative_to_this_file, dir, '*.rb')
  Dir[glob].each { |file| require file }
end

require_all.call 'transforms'
require_all.call 'sources'
require_all.call 'destinations'
require_all.call 'validations'

module GS
  module ETL
    class TestProcessor
      include GS::ETL::Logging
      GS::ETL::Logging.one_row

      attr_reader :runnable_steps, :attachable_input_step, :attachable_output_step
      attr_writer :source_columns

      FILE_LOCATION = '/tmp/'
      SCHOOL_TYPE_STRING = 'public.charter'
      ENTITIES = %w(school state district)
      COLUMN_ORDER = [ :year, :entity_type, :entity_level, :state_id, :school_id, :school_name,
                       :district_id, :district_name, :test_data_type, :gsdata_test_data_type_id, :grade,
                       :subject, :academic_gsdata_id, :breakdown, :breakdown_gsdata_id, :proficiency_band,
                       :proficiency_band_gsdata_id, :level_code, :number_tested, :value_float]
      GSDATA_COLUMNS = %w[
        source_name date_valid notes 
        description value_float state district_id 
        school_id gsdata_test_data_type_id 
        source_name number_tested grade 
        proficiency_band_gsdata_id gsdata_source_id
        breakdown_gsdata_id
        academic_gsdata_id
      ]
      REQUIRED_GSDATA_COLUMNS = %w[
        source_name date_valid notes 
        description value_float state
        gsdata_source_id
        breakdown_gsdata_id
        academic_gsdata_id
      ]
      SUMMARY_OUTPUT_FIELDS = %i[entity_level field value count]

      def initialize(input_dir, options = {})
        @input_dir = input_dir
        @options = options
        @runnable_steps = []

        instance_exec(&self.class.before) if self.class.before
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
        StepsBuilder.new(source)
      end

      def output_files_step_tree
        self.class.define_output_files
        build_file_output_steps
        output_files_root_step
      end

      def config_step
        @config_step ||= LoadConfigFile.new config_output_file, config_hash
      end

      def summary_output_step
        @summary_output_step ||= SummaryOutput.new(%i[
                                                       entity_level
                                                       year
                                                       gsdata_test_data_type_id
                                                       grade
                                                       level_code
                                                       academic_gsdata_id
                                                       breakdown_gsdata_id
                                                       proficiency_band_gsdata_id
                                                   ]
        )
      end

      class << self

        def before(&block)
          if block_given?
            @before_block = block
          else
            @before_block
          end
        end

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
        ::ColumnValueReport.new('/tmp/column_value_report.txt', :grade, :breakdown_id)
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
        @runnable_steps << summary_output_step
        shared_leaf.transform("Adds data_type_id column for config file", WithBlock) do |row|
         row[:data_type_id] = row[:test_data_type_id]
         row
        end.add(config_step)
      end

      def context_for_sources
        {dir: @input_dir, max: @options[:max], offset: @options[:offset]}
      end

      def run
        build_graph
        @sources.each do |source|
          source.run(context_for_sources)
        end
        @runnable_steps << config_step
        @runnable_steps.each(&:run)
        GS::ETL::Logging.logger.finish if GS::ETL::Logging.logger
      end

      private

      def build_file_output_steps
        initialize_queue
        source_steps
        state_steps
        district_steps
        school_steps
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
          define_method("#{entity}_output_sql_file".to_sym) do
            FILE_LOCATION +  data_file_prefix + entity + ".sql"
          end
        end
      end

      def summary_output_file
        FILE_LOCATION +  data_file_prefix + 'summary_report.csv'
      end

      def source_output_sql_file
        FILE_LOCATION +  data_file_prefix + "source.sql"
      end

      def queue_output_file
        FILE_LOCATION + ['queue.config', state,  @year ,'test.1.txt'].join('.')
      end

      def initialize_queue
        @queue_file = QueueFile.new(queue_output_file)
      end

      def source_steps
        node = output_files_root_step.add_step('Keep only state rows for source', KeepRows, :entity_level, 'state')
        sources = {}
        node = node.transform 'Find unique source', WithBlock do |row|
            source_key = [config_hash[:date_valid],row[:notes],row[:description]]
            unless sources[source_key]
              row[:entity_level] = 'source' 
              sources[source_key] = true
            end      
          row
        end
        node = node.transform('Keep rows for source', KeepRows, :entity_level, 'source')
        node.sql_writer 'Output source rows to SQL file', SqlDestination, source_output_sql_file, config_hash, GSDATA_COLUMNS, REQUIRED_GSDATA_COLUMNS
        node
      end

      def state_steps
        output_files_root_step.add(summary_output_step)
        node = output_files_root_step.add_step('Keep only state rows', KeepRows, :entity_level, 'state')
        node = node.transform 'Fill a bunch of columns with "state"', WithBlock do |row|
          row[:state_id] = 'state'
          row[:school_id] = 'state'
          row[:school_name] = 'state'
          row[:district_name] ='state'
          row[:district_id] = 'state'
          row
        end
        node.destination 'Output state rows to CSV', CsvDestination, state_output_file, *COLUMN_ORDER
        node = node.transform 'Fill a bunch of columns with "state"', WithBlock do |row|
          row[:school_id] = 'NULL'
          row[:district_id] = 'NULL'
          row
        end
        node = node.transform 'Check n_tested"', WithBlock do |row|
          row[:number_tested] = 'NULL' if row[:number_tested].nil?
          row
        end
        node.sql_writer 'Output state rows to SQL file', SqlDestination, state_output_sql_file, config_hash, GSDATA_COLUMNS, REQUIRED_GSDATA_COLUMNS
        node
      end

      def district_id_hash
        GsIdsFetcher.new('ditto', config_hash[:state],'district').hash
      end
      
      def district_steps
        output_files_root_step.add(summary_output_step)
        district_ids = district_id_hash
        node = output_files_root_step.add_step('Keep only district rows', KeepRows, :entity_level, 'district')
        node = node.transform 'Fill a couple columns with "district"', Fill,
          school_id: 'district',
          school_name: 'district'
        node.destination 'Output district rows to CSV', CsvDestination, district_output_file, *COLUMN_ORDER
        queue_hash = {}
        node = node.transform 'Fill a bunch of columns with "state"', WithBlock do |row|
          row[:school_id] = 'NULL'
          if district_ids[row[:state_id]].nil? and !queue_hash.key?(row[:state_id])
            queue_hash[row[:state_id]] = true
            @queue_file.write_queue(row)
            row[:district_id] = 'ADD NEW DISTRICT'
          elsif district_ids[row[:state_id]].nil?
            row[:district_id] = 'ADD NEW DISTRICT'
          elsif district_ids[row[:state_id]]
            row[:district_id] = district_ids[row[:state_id]]
          end
          row
        end
        node = node.transform 'Check n_tested"', WithBlock do |row|
          row[:number_tested] = 'NULL' if row[:number_tested].nil?
          row
        end
        node.sql_writer 'Output district rows to SQL file', SqlDestination, district_output_sql_file, config_hash, GSDATA_COLUMNS, REQUIRED_GSDATA_COLUMNS
        node
      end

      def school_id_hash
        GsIdsFetcher.new('ditto', config_hash[:state],'school').hash
      end

      def school_steps
        output_files_root_step
          .add(summary_output_step)
          .destination('Output summary data to file', CsvDestination, summary_output_file, *SUMMARY_OUTPUT_FIELDS)
        school_ids = school_id_hash
        district_ids = district_id_hash
        node = output_files_root_step.add_step('Keep only school rows', KeepRows, :entity_level, 'school')
        node.destination 'Output school rows to CSV', CsvDestination, school_output_file, *COLUMN_ORDER
        queue_hash = {}
        node = node.transform 'Fill a bunch of columns with "state"', WithBlock do |row|
          row[:gs_district_id] = district_ids[row[:district_id]]
          row[:district_id] = 'NULL'
          if school_ids[row[:state_id]].nil? and !queue_hash.key?(row[:state_id])
            queue_hash[row[:state_id]] = true
            @queue_file.write_queue(row)
            row[:school_i] = 'ADD NEW SCHOOL'
          elsif school_ids[row[:state_id]].nil?
            row[:school_i] = 'ADD NEW SCHOOL'
          elsif school_ids[row[:state_id]]
            row[:school_id] = school_ids[row[:state_id]]
          end
          row
        end
        node = node.transform 'Check n_tested"', WithBlock do |row|
          row[:number_tested] = 'NULL' if row[:number_tested].nil?
          row
        end
        node.sql_writer 'Output school rows to SQL file', SqlDestination, school_output_sql_file, config_hash, GSDATA_COLUMNS, REQUIRED_GSDATA_COLUMNS
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
        source
      end

      def union_steps(*steps)
        step = Step.new
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
