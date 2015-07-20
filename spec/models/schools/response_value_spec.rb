require 'spec_helper'

describe ResponseValue do

  describe '#response_label' do
    let(:locale) { :es }
    let(:translations) do
      {
        'response_value' => {
          'Hello World' => 'Hola Mundo'
        }
      }
    end
    before do
      I18n.backend = I18n::Backend::KeyValue.new({})
      I18n.backend.store_translations(locale, translations)
      I18n.locale = locale
    end
    it 'should be translated' do
      subject['response_label'] = 'Hello World'
      expect(subject.response_label).to eq 'Hola Mundo'
    end
  end
end