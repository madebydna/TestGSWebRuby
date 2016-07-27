module GsI18n
  class Manager
    require 'find'
    attr_accessor :files
    attr_accessor :filenames
    BASE_PATH = 'config/locales'.freeze

    def locales
      I18n.available_locales
    end

    def self.find_filenames(pattern = nil)
      pattern ||= '.*\.yml$'
      Find.find(BASE_PATH).select do |path|
        path =~ /#{pattern}/
      end
    end

    def self.for_files_with_pattern(pattern = nil)
      self.new(find_filenames(pattern))
    end

    def initialize(filenames = nil)
      self.filenames = filenames || self.class.find_filenames
    end

    def files
      @files ||= filenames.map { |f| GsI18n::I18nFile.new(f) }
    end

    def files_grouped_by_name
      files.group_by(&:name_minus_locale)
    end

    def self.translate_and_add_db_value(table_dot_column, strings, translate = false)
      strings = [*strings]
      manager = Manager.for_files_with_pattern(table_dot_column)
      strings.each do |s|
        manager.files_grouped_by_name.each_with_index do |(name, files), index|
          file_group = GsI18n::FileGroup.new(files)
          file_group.add_new_key_and_value(GsI18n.clean_key(s), s, translate)
          file_group.write_each_if_dirty
        end
      end
    end

    def check_missing_translations
      # YAML::ENGINE.yamler = 'syck'
      files_grouped_by_name.each_with_index do |(name, files), index|
        file_group = FileGroup.new(files)
        missing = file_group.missing_translations
        if missing.present?
          puts
          puts '=' * 75
          puts "I18n file(s): #{files.first.name_minus_locale}.xx.yml"
          puts '-' * 75
          puts "Keys not present in all locales:\n"
          missing.each do |key|
            puts key
          end
          puts
        end
      end
      nil
    end

    def copy_missing_translations
      files_grouped_by_name.each_with_index do |(name, files), index|
        file_group = FileGroup.new(files)
        missing = file_group.missing_translations
        added_translations_messages = file_group.copy_missing_translations if missing.present?
        file_group.write_each_if_dirty
        if added_translations_messages.present?
          puts
          puts '=' * 75
          puts "I18n file(s): #{files.first.name_minus_locale}.xx.yml"
          puts '-' * 75
          added_translations_messages.compact.each { |msg| puts msg }
        end
      end

      nil
    end

    def sort!
      files.each do |f|
        f.sort!
        f.write
      end
    end
  end
end
