module GsI18n
  # Represents a group of I18n files across locales
  class FileGroup
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

    def add_new_key_and_value(key, value, translate=false)
      files.each do |f|
        translation = f.translation(key).presence
        next if translation
        locale = f.filename_locale
        value = translate(locale, value) if translate
        f.add_translation!(key, value)
      end
    end

    def translate(lang, value)
      return value if lang == :en
      begin
        EasyTranslate.translate(value, to: lang, key: 'AIzaSyDhj9L6M-R-GiFUDk5-OnWG8oI8GYJMSho')
      rescue EasyTranslate::EasyTranslateException => e
        # From https://stackoverflow.com/questions/33889673/translate-api-user-rate-limit-exceeded-403-without-reason
        if e.message == 'User Rate Limit Exceeded'
          puts "Rate limit exceeded. Trying again in 100 seconds..."
          sleep(100)
          retry
        else
          raise
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

    def write_each
      files.each(&:write)
    end
  end
end

