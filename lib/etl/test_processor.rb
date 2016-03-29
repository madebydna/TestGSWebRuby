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
        self.class.define_entity_methods
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
      end

      def output_files_root_step
        @_output_files_root_step ||= (
          Step.new
        )
      end

      def self.define_output_files
        ENTITIES.each do |entity|
          define_method("#{entity}_output_file".to_sym) do
            FILE_LOCATION +  data_file_prefix + entity + ".tree4.txt"
          end
        end
      end

      def self.define_entity_methods
        ENTITIES.each do |entity|
          define_method("#{entity}_steps".to_sym) do
            node = output_files_root_step.add_step(KeepRows, [entity], :entity_level)
            node.destination CsvDestination,
              send("#{entity}_output_file".to_sym),
              *COLUMN_ORDER
            node
          end
        end
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
        FILE_LOCATION + ['config', state,  @year ,'test.1.JZW.txt'].join('.')
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
