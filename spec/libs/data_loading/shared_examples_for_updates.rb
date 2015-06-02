require 'spec_helper'
shared_examples 'an update' do |update_class, required_update_keys|

  describe 'validations' do
    let(:valid_update) {
      {
          action: :disable,
          created: '2013-05-04',
          entity_type: :school,
          entity_id: 23,
          entity_state: 'AK',
          member_id: 123,
          value: 34
      }
    }

    # No need to initialize a CensusDataType factory for this spec
    before do
      [:value_type, :id].each do |method|
        allow_message_expectations_on_nil
        allow(nil).to receive(method).and_return(nil)
      end
    end

    required_update_keys.each do |required_key|
      it "should raise an error like #{required_key} if there is no #{required_key}" do
        invalid_update = valid_update.clone
        invalid_update.delete(required_key)
        if update_class == EspResponseLoading::Update
          next if required_key == :entity_type
          expect { update_class.new('data type', invalid_update, nil) }.to raise_error(/#{required_key}/)
        elsif update_class == SchoolLoading::Update
          expect { update_class.new('data type', invalid_update) }.to raise_error(/#{required_key}/)
        else
          expect { update_class.new(nil, invalid_update) }.to raise_error(/#{required_key}/)
        end
      end
    end

    if update_class == CensusLoading::Update
      it 'should not raise an error if doing census and the value is present but blank' do
        blank_value_update = valid_update.clone
        blank_value_update[:value] = ''
        expect { update_class.new(nil, blank_value_update) }.to_not raise_error
      end
    end
  end

end