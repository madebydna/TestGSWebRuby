require 'spec_helper'

describe ConstructFromHash do

  let(:klass) do
    c = Class.new
    c.send(:attr_accessor, :foo)
    c.send(:include, ConstructFromHash)
  end

  describe '.define_initialize_that_accepts_hash' do
    subject { klass.new(foo: 123) }
    context 'before define_initialize_that_accepts_hash called' do
      it 'should raise an error' do
        expect { subject }.to raise_error(ArgumentError)
      end
    end
    context 'after define_initialize_that_accepts_hash called' do
      before do
        klass.send(:define_initialize_that_accepts_hash)
      end
      it 'should not raise an error' do
        expect { subject }.to_not raise_error
      end
      its(:foo) { is_expected.to eq(123) }
    end
  end

  describe '#delegating_attr_accessor' do
    let(:foo) do
      Class.new do
        def initialize(*args)

        end
      end
    end
    it 'Makes mutator method delegate to #new method of specified class' do
      expect { klass.send(:delegating_attr_accessor, :foo, foo) }.to change {
        o = klass.new
        o.foo = 123
        o.foo }.from(123).to(be_a(foo))
    end
    it '#creates an accessor method for given attribute' do
      expect { klass.send(:delegating_attr_accessor, :bar, foo) }.to change {
                                                                       klass.new.respond_to?(:bar)
                                                                     }.from(false).to(true)
    end
  end




end