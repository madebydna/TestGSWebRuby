require 'spec_helper'

describe NumberToWord do

  before { I18n.locale = :en }

  describe '.human_readable_number' do
    context 'returns the correct word' do
      it 'can output thouands' do
        expect(::NumberToWord.human_readable_number(1000)).to eq('1.0 thousand')
      end

      it 'can output millions' do
        expect(::NumberToWord.human_readable_number(1691000)).to eq('1.6 million')
      end

      it 'can output billions' do
        expect(::NumberToWord.human_readable_number(1100000000)).to eq('1.1 billion')
      end

      it 'can deal with floats' do
        expect(::NumberToWord.human_readable_number(1100000000.14)).to eq('1.1 billion')
      end

      it 'can read strings' do
        expect(::NumberToWord.human_readable_number('1100000000014')).to eq('1.1 trillion')
      end 

      it 'returns the same value if less than 1000' do
        expect(::NumberToWord.human_readable_number(992)).to eq('992')
      end
    end

    it 'raises an error when the argument is not valid' do
      expect{::NumberToWord.human_readable_number('1.1.1')}.to raise_error(ArgumentError).with_message(/not a valid number/)
    end
  end 
end
