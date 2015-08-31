require 'spec_helper'

describe CommunityScorecardsController do

  let(:table_fields) do
    [
      { data_type: :school_info, partial: :school_info },
      { data_type: :a_through_g, partial: :percent_value },
      { data_type: :graduation_rate, partial: :percent_value },
    ]
  end

  describe '#set_mobile_dropdown_instance_var!' do
    before { controller.instance_variable_set(:@table_fields, table_fields) }

    it 'should set an array of arrays with [label, key, options_hash] as the values of the array' do
      controller.set_mobile_dropdown_instance_var!
      dropdown_vars = controller.instance_variable_get(:@data_type_dropdown_for_mobile)

      dropdown_vars.each do | options_array |
        expect(options_array[0]).to be_a String
        expect(options_array[1]).to be_a Symbol
        options_hash = options_array[2]
        expect(options_hash).to be_a Hash
        expect(options_hash.keys).to include(:class, :data)
        expect(options_hash[:class]).to include('js-drawTable')
        expect(options_hash[:data].keys).to include('sort-by')
        expect(options_hash[:data]['sort-by']).to eql(options_array[1])
      end

    end

  end

end
