# encoding: utf-8
module GsI18n
  def db_t(key, *args)
    default = args.first[:default] if args.first.is_a?(Hash) && args.first[:default]
    if key.blank?
      GSLogger.warn(:i18n, nil, vars: [key] + args, message: 'db_t received blank key')
      return default || key
    end
    cleansed_key = key.to_s.gsub('.', '').strip
    cleansed_key = cleansed_key.to_sym if key.is_a?(Symbol)
    self.t(cleansed_key, *args)
  end

  def translation_view_array
    case I18n.locale
    when :en
      ['es', 'En Español', 'spanish']
    when :es
      [nil, 'In English', 'english']
    else
      ['es', 'En Español', 'spanish']
    end
  end

  class I18nManager
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
      @files ||= filenames.map { |f| I18nFile.new(f) }
    end

    def files_grouped_by_name
      files.group_by(&:name_minus_locale)
    end

    def check_missing_translations
      # YAML::ENGINE.yamler = 'syck'
      files_grouped_by_name.each_with_index do |(name, files), index|
        file_group = I18nFileGroup.new(files)
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
        file_group = I18nFileGroup.new(files)
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

  # Represents a group of I18n files across locales
  class I18nFileGroup
    attr_accessor :files
    def initialize(files)
      self.files = files
    end

    def missing_translations
      @_missing_translations ||= begin
        union = files.map(&:i18n_keys).reduce(:|)
        intersection = files.map(&:i18n_keys).reduce(:&)
        union - intersection
      end
    end

    def missing_translations_per_file
      @_missing_translations_per_file ||= begin
        files.each_with_object({}) do |f, hash|
          missing_keys_for_file = missing_translations.select { |key| f.translation(key).nil? }
          hash[f] = missing_keys_for_file if missing_keys_for_file.present?
        end
      end
    end

    def find_translation(key)
      files.each do |f|
        translation = f.translation(key).presence
        return translation if translation
      end
    end

    def copy_missing_translations
      missing_translations_per_file.map do |f, translations|
        translations.map do |key|
          translation = find_translation(key)
          f.add_translation!(key, translation) unless f.translation(key).present?
        end
      end.reduce(:+)
    end

    def write_each_if_dirty
      files.each(&:write_if_dirty)
    end
  end

  class I18nFile
    attr_accessor :filename, :yaml_to_write

    def initialize(filename)
      self.filename = filename
    end

    def self.flat_hash(h,f=[],g={})
      return g.update({ f=>h }) unless h.is_a? Hash
      h.each { |k,r| flat_hash(r,f+[k],g) }
      Hash[g.map{ |k,v| [k.join('.'),v] }]
    end

    def reset_memoizations
      @_yaml = nil
      @_yaml_to_write = nil
    end

    def read
      f = File.open(filename, "r:UTF-8")
      content = f.read.dup
      f.close
      content
    end

    def yaml_to_write
      @yaml_to_write || yaml
    end

    def yaml
      @_yaml ||= YAML.load(read)
    end

    def write_if_dirty
      write if dirty?
    end

    def write
      f = File.open(filename, 'w')
      f << YAML.dump(yaml_to_write)
      f.close
      reset_memoizations
    end

    def flat_hash
      I18nFile.flat_hash(yaml)
    end

    def i18n_keys
      @i18n_keys ||= flat_hash.keys.map { |k| k[3..-1] }
    end

    def name_minus_locale
      filename[0..-8]
    end

    def yaml_locale
      yaml.keys.first.to_sym
    end

    def filename_locale
      filename[-6..-5].to_sym
    end

    def add_translation!(key, value)
      key = [filename_locale, key].join('.') unless key.start_with?(filename_locale)
      scope = key.split('.')
      hash = scope.reverse.inject(value) { |a, n| { n => a } }
      before = yaml_to_write.to_s

      self.yaml_to_write = yaml_to_write.deep_merge(hash) { |key, left, right| left }
      if yaml_to_write.to_s == before
        "Could not add key \"#{key}\" with value \"#{value}\", probably due to key hierarchy"
      else
        "Added key \"#{key}\" with value \"#{value}\"" unless yaml_to_write.to_s == before
      end
    end

    def translation(key)
      scope = key.split('.')
      yaml.seek(filename_locale.to_s, *scope)
    end

    def dirty?
      yaml_to_write.to_s != yaml.to_s
    end

    def sort!
      self.yaml_to_write = yaml_to_write.gs_sort_by_key(true)
    end
  end
end
