require 'spec_helper'
require 'i18n/tasks'
require 'i18n/tasks/commands'

describe 'I18n' do

  let(:i18n) { I18n::Tasks::BaseTask.new }
  let(:missing_keys) { i18n.missing_keys }
  let(:unused_keys) { i18n.unused_keys }

  before do
  end

  GsI18n::I18nManager.new.files.each do |i18n_file|
    describe "#{i18n_file.filename}" do

    end
    it "#{i18n_file.filename} should use locale #{i18n_file.filename_locale}" do
      expect(i18n_file.yaml_locale).to eq(i18n_file.filename_locale)
    end
  end

  it 'does not have missing keys' do
    expect(missing_keys).to be_empty,
      "Missing #{missing_keys.leaves.count} i18n keys, run `i18n-tasks missing' to show them"
  end

  it 'has a db_t method' do
    expect(I18n).to respond_to(:db_t)
  end

  describe '.db_t' do
    before do
      allow(I18n).to receive(:t)
    end
    it 'should remove periods from key' do
      key = 'foo.bar'
      expect(I18n).to receive(:t).with('foobar')
      I18n.db_t(key)
    end

    it 'should pass on options hash' do
      key = 'foo.bar'
      expect(I18n).to receive(:t).with('foobar', default: 'default')
      I18n.db_t(key, default: 'default')
    end

    it 'should accept symbols as arguments' do
      key = :'foo.bar'
      expect(I18n).to receive(:t).with(:foobar)
      I18n.db_t(key)
    end

    context 'when given blank key' do
      [nil, ''].each do |blank_key|
        it 'should return default value when one provided' do
          expect(I18n).to_not receive(:t)
          result = I18n.db_t(blank_key, default: 'default')
          expect(result).to eq('default')
        end
        it 'should return key if no default provided' do
          expect(I18n).to_not receive(:t)
          result = I18n.db_t(blank_key)
          expect(result).to eq(blank_key)
        end
      end
    end
  end
  
  it 'has an non_default_locale method' do
    expect(I18n).to respond_to(:non_default_locale)
  end

  describe '.non_default_locale' do
    before do
      allow(I18n).to receive(:default_locale).and_return(:en)
    end

    context 'with current locale the default locale' do
      before do 
        allow(I18n).to receive(:locale).and_return(:en)
      end
      it 'should return empty string' do
        expect(I18n.non_default_locale).to eq(nil)
      end

    end

    context 'with current locale not the default locale' do

      context 'with current locale available' do
        before do 
          allow(I18n).to receive(:locale).and_return(:es)
        end
        it 'should return current local as string' do
          expect(I18n.non_default_locale).to eq('es')
        end
      end

      context 'with current locale not available' do
        before do 
          allow(I18n).to receive(:locale).and_return(:xx)
          allow(I18n).to receive(:locale_available?).with(:xx).and_return(false)
        end
        it 'should return current local as string' do
          expect(I18n.non_default_locale).to eq(nil)
        end
      end

    end
  end

end

