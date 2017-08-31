require 'spec_helper'

describe FromHashMethod do
  let(:receiving_class) do
    Class.new do
      attr_accessor :foo, :bar
      include FromHashMethod
    end
  end

  let(:hash) do
    {}
  end

  subject(:receiving_class_instance) do
    receiving_class.from_hash(hash)
  end

  context 'when hash keys are strings' do
    let(:hash) do
      {
        'foo' => 1,
        'bar' => 2
      }
    end
    its(:foo) { is_expected.to eq(1) }
    its(:bar) { is_expected.to eq(2) }
  end

  context 'when hash keys are symbols' do
    let(:hash) do
      {
        foo: 1,
        bar: 2
      }
    end
    its(:foo) { is_expected.to eq(1) }
    its(:bar) { is_expected.to eq(2) }
  end

  context 'when key doesnt match a method' do
    let(:hash) do
      {
        not_a_method: 1,
        also_not_a_method: 2
      }
    end
    it 'logs error using GSLogger' do
      expect(GSLogger).to receive(:error).exactly(hash.keys.size).times
      subject
    end
    it { is_expected.to be_a(receiving_class) }
  end

end
