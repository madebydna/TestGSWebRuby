require_relative './file_logger'
require_relative '../states' # FIXME: This require is outside the etl directory
require_relative './logging'
require_relative './row'
require_relative './gs_ids_fetcher'
require_relative './state_gs_id_mapping'

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
    class MetricsProcessor
      include GS::ETL::Logging
      GS::ETL::Logging.one_row

      attr_reader :runnable_steps, :attachable_input_step, :attachable_output_step
      attr_writer :source_columns

      #FILE_LOCATION = '/tmp/'
      USER = `echo $(whoami)`.chomp!
      FILE_LOCATION = "/Users/#{USER}/Documents/Metrics_Load/Metrics_Output/"
      SCHOOL_TYPE_STRING = 'public.charter'
      ENTITIES = %w(school state district)
      COLUMN_ORDER = [ :year, :entity_type, :gs_id, :state_id,
                       :district_name, :school_name, :data_type, :data_type_id, :grade,
                       :subject, :subject_id, :breakdown, :breakdown_id,
                       :cohort_count, :value]                       

      COLUMNS = %w[
        entity_type gs_id
        date_valid notes 
        description value state data_type_id 
        cohort_count grade source_id
        breakdown_id
        subject_id
      ]
      REQUIRED_COLUMNS = %w[
        entity_type gs_id
        date_valid notes 
        value state data_type_id 
        grade source_id
        breakdown_id
        subject_id
      ]

      SUMMARY_OUTPUT_FIELDS = %i[entity_type field value count]

      def initialize(input_dir, options = {})
        @input_dir = input_dir
        @options = options
        @runnable_steps = []
        @load_type = 'metrics'

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

      def summary_output_step
        @summary_output_step ||= SummaryOutput.new(%i[
                                                       entity_type
                                                       year
                                                       data_type_id
                                                       grade
                                                       subject_id
                                                       breakdown_id
                                                       proficiency_band_id
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
        ::ColumnValueReport.new("#{FILE_LOCATION}column_value_report.txt", :grade, :breakdown_id)
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
      end

      def context_for_sources
        {dir: @input_dir, max: @options[:max], offset: @options[:offset]}
      end

      def run
        build_graph
        @sources.each do |source|
          source.run(context_for_sources)
        end
        @runnable_steps.each(&:run)
        #zip_output_files
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

      def zip_output_files
        ENTITIES.each do |entity|
          `gzip -f "#{FILE_LOCATION}#{data_file_prefix}#{entity}.sql"`
        end
      end

      def summary_output_file
        FILE_LOCATION +  data_file_prefix + 'summary_report.csv'
      end

      def source_output_sql_file
        FILE_LOCATION +  data_file_prefix + "dataset.sql"
      end

      def queue_output_file
        FILE_LOCATION + ['queue.config', state,  @year ,'test.1.txt'].join('.')
      end

      def initialize_queue
        @queue_file = QueueFile.new(queue_output_file)
      end

      def source_steps
        sources = {}
        node = output_files_root_step.add_step('Keep only state rows for source', KeepRows, :entity_type, 'school','district','state')
        node = node.transform 'Find unique source', WithBlock do |row|
            source_key = [row[:date_valid],row[:data_type_id],row[:notes],row[:description]]
              unless sources[source_key]
                row[:entity_type] = 'source' 
                sources[source_key] = true
                row[:gs_id] = 0
                row[:description] = 'NULL' 
              end      
            row
        end
        node = node.transform('Keep rows for source', KeepRows, :entity_type, 'source')
        node.sql_writer 'Output source rows to SQL file', SqlDestination, source_output_sql_file, config_hash, COLUMNS, REQUIRED_COLUMNS, @load_type
        node
      end

      def state_id_hash
        StateIdMapping.new.state_gs_id_mapping
      end

      def state_steps
        output_files_root_step.add(summary_output_step)
        state_ids = state_id_hash
        node = output_files_root_step.add_step('Keep only state rows', KeepRows, :entity_type, 'state')
        node = node.transform 'Fill a bunch of columns with "state"', WithBlock do |row|
          row[:state_id] = 'state'
          row[:school_name] = 'state'
          row[:district_name] ='state'
          if state_ids[config_hash[:state].upcase].nil?
            row[:gs_id] = 'CHECK STATE VALUE'
          else
            row[:gs_id] = state_ids[config_hash[:state].upcase]
          end
          row
        end     
        node = node.transform 'Check cohort/breakdown_id/subject_id/grade', WithBlock do |row|
          row[:cohort_count] = 'NULL' if row[:cohort_count].nil?
          row[:cohort_count] = 'NULL' if row[:cohort_count] == 'NA'
          row[:cohort_count] = 'NULL' if row[:cohort_count].include? '>'
          row[:cohort_count] = 'NULL' if row[:cohort_count].include? '<'
          row[:breakdown_id] = 0 if row[:breakdown_id].nil?
          row[:subject_id] = 0 if row[:subject_id].nil?
          if row[:grade].nil?
            row[:grade] = 'NA' 
          else
            row[:grade] = row[:grade].gsub(/^0/, '')
          end
          row
        end
        node.destination 'Output state rows to CSV', CsvDestination, state_output_file, *COLUMN_ORDER
        node.sql_writer 'Output state rows to SQL file', SqlDestination, state_output_sql_file, config_hash, COLUMNS, REQUIRED_COLUMNS, @load_type
        node
      end

      def district_id_hash
        GsIdsFetcher.new('ditto', config_hash[:state],'district').hash
      end
      
      def district_steps
        output_files_root_step.add(summary_output_step)
        district_ids = district_id_hash
        node = output_files_root_step.add_step('Keep only district rows', KeepRows, :entity_type, 'district')
        node = node.transform 'Fill a couple columns with "district"', Fill,
          school_name: 'district'
        queue_hash = {}
        node = node.transform 'Match district gs_id', WithBlock do |row|
          if district_ids[row[:state_id]].nil? and !queue_hash.key?(row[:state_id])
            queue_hash[row[:state_id]] = true
            @queue_file.write_queue(row)
            row[:gs_id] = 'ADD NEW DISTRICT'
          elsif district_ids[row[:state_id]].nil?
            row[:gs_id] = 'ADD NEW DISTRICT'
          elsif district_ids[row[:state_id]]
            row[:gs_id] = district_ids[row[:state_id]]
          end
          row
        end
        node = node.transform 'Check cohort/breakdown_id/subject_id/grade', WithBlock do |row|
          row[:cohort_count] = 'NULL' if row[:cohort_count].nil?
          row[:cohort_count] = 'NULL' if row[:cohort_count] == 'NA'
          row[:cohort_count] = 'NULL' if row[:cohort_count].include? '>'
          row[:cohort_count] = 'NULL' if row[:cohort_count].include? '<'
          row[:breakdown_id] = 0 if row[:breakdown_id].nil?
          row[:subject_id] = 0 if row[:subject_id].nil?
          if row[:grade].nil?
            row[:grade] = 'NA' 
          else
            row[:grade] = row[:grade].gsub(/^0/, '')
          end
          row
        end
        node.destination 'Output district rows to CSV', CsvDestination, district_output_file, *COLUMN_ORDER
        node.sql_writer 'Output district rows to SQL file', SqlDestination, district_output_sql_file, config_hash, COLUMNS, REQUIRED_COLUMNS, @load_type
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
        node = output_files_root_step.add_step('Keep only school rows', KeepRows, :entity_type, 'school')
        
        queue_hash = {}
        node = node.transform 'Fill a bunch of columns with "state"', WithBlock do |row|
          if school_ids[row[:state_id]].nil? and !queue_hash.key?(row[:state_id])
            queue_hash[row[:state_id]] = true
            @queue_file.write_queue(row)
            row[:gs_id] = 'ADD NEW SCHOOL'
          elsif school_ids[row[:state_id]].nil?
            row[:gs_id] = 'ADD NEW SCHOOL'
          elsif school_ids[row[:state_id]]
            row[:gs_id] = school_ids[row[:state_id]]
          end
          row
        end
        node = node.transform 'Check cohort/breakdown_id/subject_id/grade', WithBlock do |row|
          row[:cohort_count] = 'NULL' if row[:cohort_count].nil?
          row[:cohort_count] = 'NULL' if row[:cohort_count] == 'NA'
          row[:cohort_count] = 'NULL' if row[:cohort_count].include? '>'
          row[:cohort_count] = 'NULL' if row[:cohort_count].include? '<'
          row[:breakdown_id] = 0 if row[:breakdown_id].nil?
          row[:subject_id] = 0 if row[:subject_id].nil?
          if row[:grade].nil?
            row[:grade] = 'NA' 
          else
            row[:grade] = row[:grade].gsub(/^0/, '')
          end        
          row
        end
        node.destination 'Output school rows to CSV', CsvDestination, school_output_file, *COLUMN_ORDER
        node.sql_writer 'Output school rows to SQL file', SqlDestination, school_output_sql_file, config_hash, COLUMNS, REQUIRED_COLUMNS, @load_type
        node
      end

      def config_hash
        #  If config hash is NOT defined by transform script should raise error
        raise ArgumentError
      end

      def data_file_prefix
        raise ArgumentError, 'Missing ticket number' if @ticket_n.nil? 
        raise ArgumentError, 'Missing year' if @year.nil? 
        [@ticket_n, state, 'metrics', @year].join('_') + '_'
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
