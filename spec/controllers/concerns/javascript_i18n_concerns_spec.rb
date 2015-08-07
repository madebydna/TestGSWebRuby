require 'spec_helper'

describe JavascriptI18nConcerns do
  let(:controller_class) do
    c = Class.new
    c.send(:include, JavascriptI18nConcerns)
    c
  end
  let(:controller) { controller_class.new }
  let(:gon) { Struct.new(:translations, :locale).new(HashWithIndifferentAccess.new) }

  let(:locale) { :es }
  let(:translations) do
    {
      en: {
        'Hello World' => 'Hello World'
      },
      es: {
        'Hello World' => 'Hola Mundo'
      }
    }
  end

  shared_context 'with I18n KeyValue backend' do
    before do
      @old_i18n_backend = I18n.backend
      @old_locale = I18n.locale
      I18n.backend = I18n::Backend::KeyValue.new({})
      translations.keys.each do |locale|
        I18n.backend.store_translations(locale, translations[locale])
      end
      I18n.locale = locale
    end
    after do
      I18n.backend = @old_i18n_backend
      I18n.locale = @old_locale
    end
  end

  describe '#add_configured_translations_to_js' do
    include_context 'with I18n KeyValue backend'
    before do
      allow(controller).to receive(:gon) { gon }
    end
    context 'english translations' do
      before do
        I18n.locale = :en
        allow(controller).to receive(:javascript_translations) { translations[I18n.locale] }
      end
      it 'should set english translations' do
        controller.send(:add_configured_translations_to_js)
        expect(gon.translations['Hello World']).to eq('Hello World')
      end
    end
    context 'spanish translations' do
      before do
        I18n.locale = :es
        allow(controller).to receive(:javascript_translations) { translations[I18n.locale] }
      end
      it 'should set spanish translations' do
        controller.send(:add_configured_translations_to_js)
        expect(gon.translations['Hello World']).to eq('Hola Mundo')
      end
    end
  end

  describe '#javascript translations' do
    it 'returns some translations' do
      translations = controller.send(:javascript_translations)
      expect(translations.values).to be_present
    end
  end

end