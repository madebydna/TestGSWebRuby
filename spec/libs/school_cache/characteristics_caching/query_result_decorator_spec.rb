require 'spec_helper'

def decorator(hash, state= 'CA')
  CharacteristicsCaching::QueryResultDecorator.new(state, Hashie::Mash.new(hash))
end

describe CharacteristicsCaching::QueryResultDecorator do

  describe '#breakdown' do
    before do
      allow(CharacteristicsCaching::Base).to receive(:characteristics_data_breakdowns).and_return( data_set_with_values )
    end

    context 'when breakdown is white' do
      let(:data_set_with_values) do
        {4 => Hashie::Mash.new({breakdown_id: 4, breakdown: 'White'})}
      end

      it 'should return white as breakdown' do
        expect(decorator(breakdown_id: 4).breakdown).to eq 'White'
      end
    end

    context 'when breakdown is all students' do
      let(:data_set_with_values) do
        {10 => Hashie::Mash.new({breakdown_id: nil, breakdown: 'All students'})}
      end

      it 'should print "All students" if ethnicities do not exist' do
        expect(decorator({}).breakdown).to eq 'All students'
      end
    end

  end
end