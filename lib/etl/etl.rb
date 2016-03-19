require 'transforms/joiner'
require 'step'
require_relative '../states'

module GS
  module ETL
    module Source
      def run
        each do |row|
          children.each do |child|
            child.inject(row) do |row, step|
              if row.is_a?(Array)
                row.map { |r| step.log_and_process(r) }
              else
                step.log_and_process(row)
              end
            end
          end
        end
      end
    end

    class StepsBuilder
      attr_accessor :step
      def initialize(step)
        @step = step
      end

      def add_step(source_class, *args, &block)
        @step = @step.add_step(source_class, *args, &block)
      end
      alias_method :transform, :add_step
      alias_method :destination, :add_step

      def method_missing(method, *args, &block)
        @step.send(method, *args, &block)
      end
    end

    class DataProcessor

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
    end
  end
end

class RunOtherStep < GS::ETL::Step
  def initialize(step)
    @step = step
  end

  def process(row)
    @step.run
    row
  end
end
