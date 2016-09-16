module GsI18n
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
      y = yaml_to_write
      f = File.open(filename, 'w')
      f << YAML.dump(y, line_width: -1)
      f.close
      reset_memoizations
    end

    def flat_hash
      File.flat_hash(yaml)
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
      key = [filename_locale, key].join('.') unless key.start_with?(filename_locale.to_s)
      scope = key.split('.')
      hash = scope.reverse.inject(value) { |a, e| { e => a } }
      before = yaml_to_write.to_s

      self.yaml_to_write = yaml_to_write.deep_merge(hash) { |_, left, right| left }
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
