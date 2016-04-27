require 'spec_helper'

describe FieldRenamer do

  describe '.initialize' do
    it 'should raise error if given "from" attribute is empty' do
      expect { FieldRenamer.new(nil, :foo) }.to raise_error
    end
    it 'should raise error if given "to" attribute is empty' do
      expect { FieldRenamer.new(:foo, nil) }.to raise_error
    end
    it 'should return new instance when given valid attributes' do
      expect(FieldRenamer.new(:foo, :bar)).to be_a(FieldRenamer)
    end
  end

  describe '#process' do
    context 'when renaming from :foo to :bar' do
      let(:renamer) { FieldRenamer.new(:foo, :bar) }
      subject { renamer.process(row) }
      describe 'when hash contains origin key' do
        let(:row) do
          {
            foo: 123
          }
        end
        it { is_expected.to_not have_key(:foo) }
        it { is_expected.to have_key(:bar) }
        it 'should have renamed field' do
          expect(subject[:bar]).to eq(123)
        end
      end

      describe 'when hash does not contain origin key' do
        it 'should raise an error' do
          expect { subject }.to raise_error
        end
      end
    end
  end

end

