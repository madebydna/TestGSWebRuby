require 'spec_helper'

describe JavascriptI18nConcerns do
  let(:controller_class) do
    c = Class.new
    c.send(:include, JavascriptI18nConcerns)
    c
  end
  let(:controller) { controller_class.new }
  let(:gon) { Struct.new(:translations).new(HashWithIndifferentAccess.new) }

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

  before do
    stub_const('JavascriptI18nConcerns::TRANSLATIONS_TO_ADD_TO_JS', ['Hello World'])

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

  describe '#add_configured_translations_to_js' do
    before do
      allow(controller).to receive(:gon) { gon }
    end
    it 'should set english translations' do
      controller.send(:add_configured_translations_to_js)
      expect(gon.translations['en']).to eq({ 'Hello World' => 'Hello World'})
    end
    it 'should set spanish translations' do
      controller.send(:add_configured_translations_to_js)
      expect(gon.translations['es']).to eq({ 'Hello World' => 'Hola Mundo'})
    end
  end

end