#!/usr/bin/env ruby
require_relative '../config/environment'
require 'optparse'
require_relative '../lib/i18n/manager.rb'

class MissingCrpeTranslationChecker
  def self.report
    MissingCrpeTranslationChecker.new.run
  end

  def self.translate(table)
    hash = MissingCrpeTranslationChecker.new.missing_translations_hash
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

  def initialize
    @config                       = [
      {
        table:  :'omni.covid_responses',
        column: :value,
        key_column: :data_type,
        key_value: 'OVERVIEW'
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
      column_check                  = new_column_checker(hash[:table], hash[:column], hash[:key_column], hash[:key_value], hash)
      @missing_translation_messages += column_check.missing_translation_messages
      puts column_check.report
    end
  end

  def missing_translations_hash
    @config.each_with_object({}) do |hash, aggregate_hash|
      column_check = new_column_checker(hash[:table], hash[:column], hash[:key_column], hash[:key_value], hash)
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
    ColumnKeyValueChecker.new(*args)
  end

  class ColumnKeyValueChecker
    attr_accessor :table, :column, :key_column, :key_value, :config

    def initialize(table, column, key_column, key_value, config = {})
      default_config_options = {
        filters:   [],
        delimiter: nil
      }
      config                 = config.reverse_merge(default_config_options)
      config.keep_if { |k| default_config_options.has_key?(k) }
      config.each_pair { |option, value| instance_variable_set("@#{option}", value) }
      @table  = table
      @column = column
      @key_value = key_value
      @key_column = key_column
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
            # rubocop:disable Style/PerlBackrefs
            text.gsub!(/([\{\[,])\s*(\w+)\s?:/) { "#{$1}\"#{$2}\":" }
            # rubocop:enable Style/PerlBackrefs
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
          # rubocop:disable Style/DoubleNegation
          @filters.any? { |filter| !!filter.match(string.to_s) }
          # rubocop:enable Style/DoubleNegation
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
      "select distinct(#{column}) from #{table} where #{key_column}='#{key_value}'"
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

  opts.banner = "Usage: missing_crpe_translation_checker.rb"

  opts.on('-tTABLE', '--translate=TABLE', 'Google translate missing strings from covid_responses') do |table|
    options.command = :translate
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
  MissingCrpeTranslationChecker.report
when :translate
  MissingCrpeTranslationChecker.translate(options.table)
end
