require 'spec_helper'
require 'i18n/tasks'
require 'i18n/tasks/commands'

describe 'I18n' do

  let(:i18n) { I18n::Tasks::BaseTask.new }
  let(:missing_keys) { i18n.missing_keys }
  let(:unused_keys) { i18n.unused_keys }

  before do
  end

  it 'does not have missing keys' do
    pending('TODO: Work on Jenkins environment to get test to work')
    fail
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
  end


end
