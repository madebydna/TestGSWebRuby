require 'optparse'

OptionParser.new do |opts|
  opts.banner = "Usage: i18n_database_check.rb [-f]"

  opts.on('-f', '--file [FILE]', 'Write output to specified file') do |v|
    $stdout.reopen(v, "w")
    $stdout.sync = true
  end

  # Cannot use -h and --help since that will be interpreted by rails runner and spit out rails runner usage
  opts.on_tail('-?', '--usage', 'Show this message') do
    puts opts
    exit
  end
end.parse!


# Example
# DATABASE_URL=mysql2://USER:PASSWORD@rodb-qa.greatschools.org/gs_schooldb bundle exec rails runner script/missing_database_translation_checker.rb -f /tmp/missing_database_translation_checker_output.txt
class MissingDatabaseTranslationChecker

  def self.run
    MissingDatabaseTranslationChecker.new.run
  end

  def initialize
    @config = [
      {
        table: :'localized_profiles.categories',
        column: :name
      },
      {
        table: :'localized_profiles.category_data',
        column: :label
      },
      {
        table: :'localized_profiles.category_placements',
        column: :title
      },
      {
        table: :'gs_schooldb.data_description',
        column: :value
      },
      {
        table: :'gs_schooldb.ethnicity',
        column: :name
      },
      # {
      #   table: :'gs_schooldb.hub_config',
      #   column: :value
      # }
      {
        table: :'localized_profiles.response_values',
        column: :response_label
      },
      {
        table: :'gs_schooldb.review_questions',
        column: :question
      },
      {
        table: :'gs_schooldb.review_questions',
        column: :responses,
        delimiter: ','
      },
      {
        table: :'gs_schooldb.review_topics',
        column: :label
      },
      {
        table: :'gs_schooldb.review_topics',
        column: :name
      },
      {
        table: :'gs_schooldb.school_members',
        column: :user_type
      },
      {
        table: :'localized_profiles.school_profile_configurations',
        column: :value,
        filters: [
          /^\d+$/,
          /^true$/,
          /^false$/
        ]
      },
      {
        table: :'gs_schooldb.TestDataBreakdown',
        column: :name,
        filters: [
          /DEPRECATED/
        ]
      },
      {
        table: :'gs_schooldb.TestDataSubject',
        column: :name,
      },
      {
        table: :'gs_schooldb.TestDataType',
        column: :description
      },
      {
        table: :'gs_schooldb.TestDataType',
        column: :display_name
      },
    ]
    @missing_translation_messages = []
  end

  def run
    check_for_missing_translations
    print_report
    exit @missing_translation_messages.size
  end

  def check_for_missing_translations
    @config.each do |hash|
      column_check = new_column_checker(hash[:table], hash[:column], hash)
      @missing_translation_messages += column_check.missing_translation_messages
      puts column_check.report
    end
  end

  def print_report
    puts '=' * 75
    @missing_translation_messages.each do |message|
      puts message
    end
    puts '-' * 75
    puts "Total number of missing translations: #{@missing_translation_messages.size}"
    puts "\n"
  end

  def new_column_checker(*args)
    ColumnChecker.new(*args)
  end


  class ColumnChecker
    attr_accessor :table, :column, :config
    def initialize(table, column, config = {})
      default_config_options = {
        filters: [],
        delimiter: nil
      }
      config = config.reverse_merge(default_config_options)
      config.keep_if { |k| default_config_options.has_key?(k) }
      config.each_pair { |option, value| instance_variable_set("@#{option}", value) }
      @table = table
      @column = column
    end

    def report
      "#{missing_translations.size} missing translations for #{table}.#{column}"
    end

    def missing_translation_messages
      missing_translations.map { |key| "Missing translation '#{key}' for #{table}.#{column}"}
    end

    def missing_translations
      @missing_translations ||= (
        default = '_missing_translation_'
        translation_keys.select do |string|
          I18n.db_t(string, default: default) == default
        end
      )
    end

    def translation_keys
      expanded_column_values - strings_to_filter_out
    end

    def expanded_column_values
      @expanded_column_values ||= (
        column_values.each_with_object([]) do |value, array|
          if value[0] == '{' && value[-1] == '}'
            hash = JSON.parse(value) rescue nil
            values = []
            values = values_from_hash(hash) if hash
            array.concat(values)
          elsif @delimiter
            array.concat(value.split(@delimiter))
          else
            array << value
          end
        end
      )
    end

    def strings_to_filter_out
      @strings_to_filter_out ||= (
        expanded_column_values.select do |string|
          @filters.any? { |filter| !!filter.match(string.to_s) }
        end
      )
    end

    # Values might be strings, integers, or strings that contain json blobs
    def column_values
      result = ActiveRecord::Base.connection.execute(build_query)
      result.to_a.map do |row|
        value = row.first
        next unless value
        value.gsub('\n', '').strip.presence
      end.compact
    end

    def build_query
      "select distinct(#{column}) from #{table}"
    end

    def values_from_hash(hash_or_array)
      array = hash_or_array.is_a?(Hash) ? hash_or_array.values : [*hash_or_array]

      array.inject([]) do |result, value|
        case value
          when Hash then result + values_from_hash(value)
          when Array then result + values_from_hash(value)
          else
            result << value
        end
      end
    end
  end
end

MissingDatabaseTranslationChecker.run