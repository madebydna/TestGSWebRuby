# frozen_string_literal: true

require 'spec_helper'

describe GsI18n do
  before(:all) do
    class FakeModel
      include GsI18n
    end
  end
  after(:all) { Object.send :remove_const, :FakeModel }
  let(:target) { FakeModel.new }

  describe '#db_t' do
    let(:subject) { target.db_t(key, args) }
    let(:args) { {default: 'Default'} }

    describe 'with a regular key' do
      let(:key) { 'Civil Rights Data Collection' }

      it 'tries to translate it' do
        expect(target).to receive(:t).and_return('Translated')
        expect(subject).to eq('Translated')
      end
    end

    describe 'with a blank key' do
      let(:key) { '' }

      it 'falls back on the default' do
        expect(target).to_not receive(:t)
        expect(subject).to eq('Default')
      end
    end

    describe 'with a strange key' do
      let(:key) { '...' }

      it 'falls back on the default' do
        expect(target).to_not receive(:t)
        expect(subject).to eq('Default')
      end
    end
  end
end