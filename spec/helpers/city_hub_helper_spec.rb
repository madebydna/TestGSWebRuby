require 'spec_helper'



describe CityHubHelper do
  describe '.abbreviate_at_whitespace' do
    let(:input) { "This is a student for this school This is a student for this school " * 10 }
    it 'abbreviates at whitespace' do
      result = helper.abbreviate_at_whitespace(input, 140)
      expected = "This is a student for this school This is a student for this school This is a student for this school This is a student for this school..."
      expect(result).to eq(expected)
    end

    context 'with a max_length not greater than 2' do
      it 'raises an error' do
        expect {
          helper.abbreviate_at_whitespace(input, 2)
        }.to raise_error(ArgumentError)
      end
    end
  end
end
