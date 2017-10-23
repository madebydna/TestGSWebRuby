module JavascriptI18nConcerns
  extend ActiveSupport::Concern

  class_methods do
    def set_additional_js_translations(hash)
      @additional_js_translations = hash
    end

    def additional_js_translations
      @additional_js_translations
    end
  end

  protected

  def add_configured_translations_to_js
    flat_translations_hash = flatten_hash(javascript_translations)
    flat_translations_hash.each do |key, value|
      add_translation_to_js(key, value)
    end
  end

  def flatten_hash(hash)
    hash.each_with_object({}) do |(k, v), h|
      if v.is_a? Hash
        flatten_hash(v).map do |h_k, h_v|
          h["#{k}.#{h_k}"] = h_v
        end
      else
        h[k] = v
      end
    end
  end

  def javascript_translations
    # ensure backend initialization for backends that support lazy initialization
    I18n.backend.send(:init_translations) if I18n.backend.respond_to?(:initialized?) && ! I18n.backend.initialized?
    translations = I18n.backend.send(:translations)
    result = translations.seek(I18n.locale, :javascript)
    (self.class.additional_js_translations || {}).each do |key, scope|
      result = result.merge(key => translations.seek(I18n.locale, *scope)) 
    end
    result
  end

  def add_translation_to_js(key, value)
    gon.translations ||= {}
    gon.translations[key] = value
  end

end
