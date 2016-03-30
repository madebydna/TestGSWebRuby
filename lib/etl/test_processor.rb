module GS
  module ETL
    class TestProcessor

      FILE_LOCATION = '/tmp/'
      SCHOOL_TYPE_STRING = 'public.charter'
      ENTITIES = ['school', 'state', 'district']
      COLUMN_ORDER = [ :year, :entity_type, :entity_level, :state_id, :school_id, :school_name,
                       :district_id, :district_name, :test_data_type, :test_data_type_id, :grade,
                       :subject, :subject_id, :breakdown, :breakdown_id, :proficiency_band,
                       :proficiency_band_id, :level_code, :number_tested, :value_float]


      def source(source_class, *args)
        source = source_class.new(*args)
        source.event_log = event_log if source.respond_to?('event_log=')
        StepsBuilder.new(source)
      end

      def event_log
        @event_log ||= EventLog.new
      end

      def output_files_step_tree
        self.class.define_output_files
        build_file_output_steps
        output_files_root_step
      end

      def config_steps
        # LoadConfigFile, config_output_file, config_hash
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
          Step.new
        )
      end

      def self.define_output_files
        ENTITIES.each do |entity|
          define_method("#{entity}_output_file".to_sym) do
            FILE_LOCATION +  data_file_prefix + entity + ".WED.txt"
          end
        end
      end

      def state_steps
        node = output_files_root_step.add_step(KeepRows, :entity_level, 'state')
        node = node.transform WithBlock do |row|
          row[:state_id] = 'state'
          row[:school_id] = 'state'
          row[:school_name] = 'state'
          row[:district_name] ='state'
          row[:district_id] = 'state'
          row
        end
        node.destination CsvDestination,
          send("state_output_file".to_sym),
          *COLUMN_ORDER
        node
      end

      def district_steps
        node = output_files_root_step.add_step(KeepRows, :entity_level, 'district')
        node = node.transform WithBlock do |row|
          row[:school_id] = 'district'
          row[:school_name] = 'district'
          row
        end
       node = node.transform Fill,
          school_id: 'district',
          school_name: 'district'
        node.destination CsvDestination,
          send("district_output_file".to_sym),
          *COLUMN_ORDER
        node
      end

      def school_steps
        node = output_files_root_step.add_step(KeepRows, :entity_level, 'school')
        node.destination CsvDestination,
          send("school_output_file".to_sym),
          *COLUMN_ORDER
        node
      end

      def config_hash
        #  If config hash is NOT defined by transform script shuould raise error
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

      def tab_delimited_source(file)
        source = CsvSource.new(file, col_sep: "\t")
        source.event_log = self.event_log
        source
      end
      
      def union_steps(*steps)
        step = GS::ETL::Step.new
        step.event_log = self.event_log
        steps.each { |s| s.add(step) }
        step
      end

      def attach(attachable)
        unless self.attachable_output_step
          raise 'Illegal state: no output step to attach graph to'
        end
        unless attachable.attachable_input_step
          raise 'Illegal state: graph has no input step to attach'
        end

        self.attachable_output_step.add(graph.attachable_input_step)
        @runnable_steps += graph.runnable_steps
        @attachable_output_step = graph.attachable_output_step
      end

    end
  end
end
