require 'spec_helper'

describe CommunitySpotlightsController do

  let(:table_fields) do
    [
      {"data_type"=>"school_info", "partial"=>"school_info"},
      {"data_type"=>"a_through_g", "partial"=>"percent_value", "year"=>2014},
      {"data_type"=>"graduation_rate", "partial"=>"percent_value", "year"=>2013}
    ].map(&:with_indifferent_access)
  end
  let(:collection_config) {
    {
      scorecard_params: {
        gradeLevel: 'h',
        schoolType: ['public', 'charter'],
        sortBy: 'a_through_g',
        sortBreakdown: 'hispanic',
        sortAscOrDesc: 'desc',
        offset: 0,
      },
      scorecard_subgroups_list: [
        :all_students,
        :african_american,
        :asian,
        :filipino,
        :hispanic,
        :multiracial,
        :native_american_or_native_alaskan,
        :pacific_islander,
        :economically_disadvantaged,
        :limited_english_proficient
      ]
    }.to_json
  }
  let(:collection) { FactoryGirl.build(:collection, config: collection_config) }

  describe '#set_mobile_dropdown_instance_var!' do
    before do
      allow(Collection).to receive(:find_by).and_return(collection)
    end

    subject do
      controller.instance_variable_set(:@table_fields, table_fields)
      controller.params[:sortBy] = 'datatype'
      controller.send(:set_mobile_dropdown_instance_var!)
      controller.instance_variable_get(:@data_type_dropdown_for_mobile)
    end

    it 'should set an array of arrays with [label, key, options_hash] as the values of the array' do
      data_types = subject.first

      data_types.each do | options_array |
        expect(options_array[0]).to be_a String
        expect(options_array[1]).to be_a String
        expect(options_array[1].to_s).to_not eq('school_info')
        options_hash = options_array[2]
        expect(options_hash).to be_a Hash
        expect(options_hash.keys).to include(:class, :data)
        expect(options_hash[:class]).to include('js-drawTable')
        expect(options_hash[:data].keys).to include('sort-by')
        expect(options_hash[:data]['sort-by']).to eql(options_array[1])
      end
    end

    it 'should set the sortBy param as the selected option' do
      expect(subject.second).to eq(controller.params[:sortBy])
    end
  end

  describe '#set_subgroups_for_header!' do
    before do
      allow(Collection).to receive(:find_by).and_return(collection)
    end

    subject do
      controller.instance_variable_set(:@table_fields, table_fields)
      controller.params[:sortBreakdown] = 'breakdown'
      controller.send(:set_subgroups_for_header!)
      controller.instance_variable_get(:@subgroups_for_header)
    end

    it 'should set an array of arrays with [label, key, options_hash] as the values of the array' do
      data_types = subject.first

      data_types.each do | options_array |
        expect(options_array[0]).to be_a String
        expect(options_array[1]).to be_a String
        options_hash = options_array[2]
        expect(options_hash).to be_a Hash
        expect(options_hash.keys).to include(:class, :data)
        expect(options_hash[:class]).to include('js-drawTable')
        expect(options_hash[:data].keys).to include('sort-breakdown')
        expect(options_hash[:data]['sort-breakdown']).to eql(options_array[1])
      end
    end

    it 'should set the sortBreakdown param as the selected option' do
      expect(subject.second).to eq(controller.params[:sortBreakdown])
    end
  end

  describe '#redirect_to_canonical_url' do
    before do
      @old_locale = I18n.locale
    end
    after do
      I18n.locale = @old_locale
    end
    [{lang: 'es'}, {}].each do |param|
      context "with params: #{param}" do
        it 'should redirect to the canonical url' do
          collection_struct = Struct.new(:url_name)
          allow(Collection).to receive(:find_by).and_return(collection_struct.new('real-name'))
          request_params = { collection_id: 1 }.merge(param)
          get :show, request_params.merge(collection_name: 'fake-name')
          expect(response).to redirect_to(community_spotlight_path(request_params.merge(collection_name: 'real-name')))
        end
      end
    end
  end
end
