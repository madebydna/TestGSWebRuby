module JavascriptI18nConcerns
  extend ActiveSupport::Concern

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
    translations.seek(I18n.locale, :javascript) || {}
  end

  def add_translation_to_js(key, value)
    gon.translations ||= {}
    gon.translations[key] = value
  end

end