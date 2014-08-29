require 'spec_helper'

def decorator(hash, state = 'CA')
  hash = hash.stringify_keys
  CharacteristicsCaching::QueryResultDecorator.new(state, Hashie::Mash.new(hash))
end

describe CharacteristicsCaching::QueryResultDecorator do
  [:school_value, :state_value].each do |field|
    method = field.to_s
    describe "##{method}" do
      it 'should prefer value_text over value_float' do
        expect(
            decorator("#{field}_text" => '10', "#{field}_value" => 20).send(method)
        ).to eq('10')
      end

      it 'should use value_float when there is no value_text' do
        expect(decorator("#{field}_float" => 20).send(method)).to eq(20)
      end
    end
  end

end