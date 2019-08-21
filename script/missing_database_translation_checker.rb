#!/usr/bin/env ruby
require_relative '../config/environment'
require 'optparse'
require_relative '../lib/i18n/manager.rb'


# Example
# DATABASE_URL=mysql2://USER:PASSWORD@rodb-qa.greatschools.org/gs_schooldb bundle exec rails runner script/missing_database_translation_checker.rb -f /tmp/missing_database_translation_checker_output.txt
class MissingDatabaseTranslationChecker

  def self.report
    MissingDatabaseTranslationChecker.new.run
  end

  def self.translate(table)
    hash = MissingDatabaseTranslationChecker.new.missing_translations_hash
    hash.select! { |key, _| key.start_with?(table) }
    hash.each do |db_dot_table_dot_column, missing_strings|
      table_dot_column = db_dot_table_dot_column.split('.')[1..-1].join('.')
      ::GsI18n::Manager.translate_and_add_db_value(
        table_dot_column,
        missing_strings,
        true
      )
    end
  end

  # Add keys and values for a table, but use the English text for all locales
  # rather than using Google Translate to translate the text
  def self.add(table)
    hash = MissingDatabaseTranslationChecker.new.missing_translations_hash
    hash.select! { |key, _| key.start_with?(table) }
    hash.each do |db_dot_table_dot_column, missing_strings|
      table_dot_column = db_dot_table_dot_column.split('.')[1..-1].join('.')
      ::GsI18n::Manager.translate_and_add_db_value(
        table_dot_column,
        missing_strings,
        false
      )
    end
  end

  def self.reformat(table)
    hash = MissingDatabaseTranslationChecker.new.missing_translations_hash
    hash.select! { |key, _| key.start_with?(table) }
    hash.each do |db_dot_table_dot_column, missing_strings|
      table_dot_column = db_dot_table_dot_column.split('.')[1..-1].join('.')
      ::GsI18n::Manager.reformat(table_dot_column)
    end
  end

  def initialize
    @config                       = [
      {
        table:  :'gs_schooldb.ethnicity',
        column: :name
      },
      {
        table:  :'gs_schooldb.review_questions',
        column: :question
      },
      {
        table:     :'gs_schooldb.review_questions',
        column:    :responses,
        delimiter: ','
      },
      {
        table:  :'gs_schooldb.review_topics',
        column: :label
      },
      {
        table:  :'gs_schooldb.review_topics',
        column: :name
      },
      {
        table:  :'gs_schooldb.school_members',
        column: :user_type
      },
      {
        table:   :'gs_schooldb.TestDataBreakdown',
        column:  :name,
        filters: [
                   /DEPRECATED/
                 ]
      },
      {
        table:  :'gs_schooldb.TestDataSubject',
        column: :name,
      },
      {
        table:  :'gs_schooldb.TestDataType',
        column: :description
      },
      {
        table:  :'gs_schooldb.TestDataType',
        column: :display_name
      },
      {
        table:  :'gs_schooldb.test_description',
        column: :description
      },
      {
        table:  :'gs_schooldb.census_description',
        column: :source
      },
      {
        table:  :'omni.data_sets',
        column: :description
      }
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
      column_check                  = new_column_checker(hash[:table], hash[:column], hash)
      @missing_translation_messages += column_check.missing_translation_messages
      puts column_check.report
    end
  end

  def missing_translations_hash
    @config.each_with_object({}) do |hash, aggregate_hash|
      column_check = new_column_checker(hash[:table], hash[:column], hash)
      aggregate_hash.merge!(column_check.missing_translations_hash)
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
        filters:   [],
        delimiter: nil
      }
      config                 = config.reverse_merge(default_config_options)
      config.keep_if { |k| default_config_options.has_key?(k) }
      config.each_pair { |option, value| instance_variable_set("@#{option}", value) }
      @table  = table
      @column = column
    end

    def report
      "#{missing_translations.size} missing translations for #{table}.#{column}"
    end

    def missing_translation_messages
      missing_translations.map { |key| "Missing translation '#{key}' for #{table}.#{column}" }
    end

    def missing_translations_hash
      {
        "#{table}.#{column}" => missing_translations
      }
    end

    def missing_translations
      @missing_translations ||= begin
        default = '_missing_translation_'
        translation_keys.select do |string|
          I18n.db_t(string, default: default) == default
        end
      end
    end

    def translation_keys
      expanded_column_values - strings_to_filter_out
    end

    def expanded_column_values
      @expanded_column_values ||= begin
        column_values.each_with_object([]) do |value, array|
          if value[0] == '{' && value[-1] == '}'
            value = value.force_encoding('windows-1252').encode('utf-8') rescue value
            text = value.dup
            text.gsub!(/\n/, '')
            text.gsub!(/\r/, '')
            text.gsub!(/([\{\[,])\s*(\w+)\s?:/) { "#{$1}\"#{$2}\":" }
            text.gsub!('\\\\', '\\')
            text.gsub!(/,( )+\]/, ']')
            text.gsub!('",}', '"}')
            text.gsub!(/( )+/, ' ')
            hash = JSON.parse(text) rescue nil
            values = []
            values = values_from_hash(hash).map(&:to_s).map(&:strip).select(&:present?) if hash
            array.concat(values)
          elsif @delimiter
            array.concat(value.split(@delimiter))
          else
            array << value
          end
        end
      end
    end

    def strings_to_filter_out
      @strings_to_filter_out ||= begin
        expanded_column_values.select do |string|
          @filters.any? { |filter| !!filter.match(string.to_s) }
        end
      end
    end

    # Values might be strings, integers, or strings that contain json blobs
    def column_values
      if is_omni?
        result = Omni::TestDataValue.connection.execute(build_query)
      else
        result = ActiveRecord::Base.connection.execute(build_query)
      end
      result.to_a.map do |row|
        value = row.first
        next unless value
        value.gsub('\n', '').strip.presence
      end.compact
    end

    def is_omni?
      table.to_s.start_with?('omni.')
    end

    def build_query
      "select distinct(#{column}) from #{table}"
    end

    def values_from_hash(hash_or_array)
      array = hash_or_array.is_a?(Hash) ? hash_or_array.values : [*hash_or_array]

      array.inject([]) do |result, value|
        case value
        when Hash
          result + values_from_hash(value)
        when Array
          result + values_from_hash(value)
        else
          result << value
        end
      end
    end
  end
end

options         = OpenStruct.new
options.command = :report
OptionParser.new do |opts|

  opts.banner = "Usage: i18n_database_check.rb [-f]"

  opts.on('-f', '--file [FILE]', 'Write output to specified file') do |v|
    $stdout.reopen(v, "w")
    $stdout.sync = true
  end

  opts.on('-tTABLE', '--translate=TABLE', 'Google translate missing strings for dot-notated db, table, and optionally column. E.g. gs_schooldb.TestSubject') do |table|
    options.command = :translate
    options.table   = table
  end

  opts.on('-aTABLE', '--add=TABLE', 'Add English text for all locales for dot-notated db, table, and optionally column. E.g. gs_schooldb.TestSubject') do |table|
    options.command = :add
    options.table   = table
  end

  opts.on('-rTABLE', '--reformat=TABLE', 'Reformat files for dot-notated db, table, and optionally column. E.g. gs_schooldb.TestSubject') do |table|
    options.command = :reformat
    options.table   = table
  end

  # Cannot use -h and --help since that will be interpreted by rails runner and spit out rails runner usage
  opts.on_tail('-?', '--usage', 'Show this message') do
    puts args
    exit
  end
  options
end.parse!

case options.command
when :report
  MissingDatabaseTranslationChecker.report
when :translate
  MissingDatabaseTranslationChecker.translate(options.table)
when :add
  MissingDatabaseTranslationChecker.add(options.table)
when :reformat
  MissingDatabaseTranslationChecker.reformat(options.table)
end
