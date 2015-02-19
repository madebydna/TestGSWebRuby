require 'spec_helper'
require 'controllers/contexts/ad_shared_contexts'
require 'controllers/examples/ad_shared_examples'

describe SearchController do
  [PaginationConcerns, GoogleMapConcerns, MetaTagsHelper, HubConcerns].each do | mod |
    it "should include #{mod.to_s}" do
      expect(SearchController.ancestors.include?(mod)).to be_truthy
    end
  end

  describe '::SOFT_FILTER_KEYS' do
    %w(beforeAfterCare dress_code boys_sports girls_sports transportation school_focus class_offerings enrollment summer_program).each do |key|
      it "should have #{key}" do
        expect(SearchController::SOFT_FILTER_KEYS).to include(key)
      end
    end
  end

  describe '#parse_filters' do

    context 'when on district browse and there is matching hub' do
      let(:params_hash) { {} }
      before do
        allow(controller).to receive(:on_district_browse?) { true }
        allow(controller).to receive(:hub_matching_current_url) { FactoryGirl.build(:hub_city_mapping) }
      end
      it 'should not filter by collection ID' do
        filters = controller.send(:parse_filters, params_hash)
        expect(filters).to_not have_key(:collection_id)
      end
    end

    context 'when on by name search and no collection ID in params, but there is matching hub' do
      let(:params_hash) { {} }
      before do
        allow(controller).to receive(:on_by_name_search?) { true }
        allow(controller).to receive(:hub_matching_current_url) { FactoryGirl.build(:hub_city_mapping) }
      end
      it 'should not filter by collection ID' do
        filters = controller.send(:parse_filters, params_hash)
        expect(filters).to_not have_key(:collection_id)
      end
    end

    context 'when on city browse and there is matching hub' do
      let(:params_hash) { {} }
      before do
        allow(controller).to receive(:on_city_browse?) { true }
        allow(controller).to receive(:hub_matching_current_url) { FactoryGirl.build(:hub_city_mapping) }
      end
      it 'should filter by collection ID' do
        filters = controller.send(:parse_filters, params_hash)
        expect(filters).to have_key(:collection_id)
      end
    end

    context 'when collection ID is in params' do
      let(:params_hash) { {'collectionId' => 1} }
      [:on_by_name_search, :on_by_location_search, :on_district_browse, :on_city_browse].each do |search_type|

        it "should filter by collection ID when #{search_type}" do
          allow(controller).to receive("#{search_type}?") { true }
          filters = controller.send(:parse_filters, params_hash)
          expect(filters[:collection_id]).to eq(1)
        end
      end
    end
  end

  describe '#ad_setTargeting_through_gon' do
    before do
      controller.instance_variable_set(:@state, short: 'CA')
    end
    subject do
      controller.send(:ad_setTargeting_through_gon)
      controller.gon.get_variable('ad_set_targeting')
    end

    include_examples 'sets specific google ad targeting attributes', %w[State]

    context 'when city does not have a county' do
      let(:city) { double('city') }
      before do
        allow(city).to receive(:county) { nil }
        controller.instance_variable_set(:@city, city)
      end
      it 'does not set the county' do
        expect(subject['County']).to be_nil
      end
    end
    context 'when city has a county' do
      let(:city) { double('city') }
      let(:county) { double('county') }
      before do
        allow(city).to receive(:county) { county }
        allow(county).to receive(:name) { 'county' }
        controller.instance_variable_set(:@city, city)
      end
      it 'sets the city county' do
        expect(subject['County']).to eq('county')
      end
    end
    {
      'PK' => 'p',
      'P' => 'p',
      'KG' => 'e',
      'K' => 'e',
      '5' => 'e',
      '6' => 'm',
      '8' => 'm',
      '9' => 'h',
      'UG' => nil,
      'AE' => nil,
      'junk' => nil,
      '' => nil,
      nil => nil
    }.each_pair do |grade, level_code|
      context "when filtering by grade #{grade}" do
        before { controller.params.merge!(grades: grade) }
        it "it sets the level to #{level_code}" do
          expect(subject['level']).to eq(level_code)
        end
      end
    end
  end

  describe '#set_global_ad_targeting_through_gon' do
    subject do
      controller.send(:set_global_ad_targeting_through_gon)
      controller.gon.get_variable('ad_set_targeting')
    end
    with_shared_context 'when ads are enabled' do
      include_example 'sets at least one google ad targeting attribute'
      include_examples 'sets specific google ad targeting attributes', %w[compfilter env]
    end
  end

  describe '#radius_param' do
    [
        ['when given radius below minimum', '0', 1],
        ['when given radius above maximum', '120', 60],
        ['when given non-numeric radius', 'foobar', 5],
        ['when given no radius', nil, 5],
    ].each do |context, input_string, expected_value|
      context "#{context}" do
        if input_string.nil?
          let (:params) { {} }
        else
          let (:params) { {'distance' => input_string} }
        end

        before do
          allow(controller).to receive(:params_hash).and_return(params)
        end

        it "should return #{expected_value}" do
          expect(controller.send(:radius_param)).to eq(expected_value)
        end

        it 'should cast to Integer' do
          expect(controller.send(:radius_param)).to be_kind_of(Integer)
        end

        it 'should record the value actually applied' do
          expect(controller).to receive(:record_applied_filter_value).with('distance', expected_value)
          controller.send(:radius_param)
        end
      end
    end

    context 'when given valid radius' do
      let (:params) { {'distance' => '15'}}

      before do
        allow(controller).to receive(:params_hash).and_return(params)
      end

      it 'should return the param supplied' do
        expect(controller.send(:radius_param)).to eq(15)
      end

      it 'should cast to Integer' do
        expect(controller.send(:radius_param)).to be_kind_of(Integer)
      end

      it 'should not record the value actually applied' do
        expect(controller).to_not receive(:record_applied_filter_value)
        controller.send(:radius_param)
      end
    end
  end

  describe '#record_applied_filter_value' do
    it 'Accepts key/value mappings' do
      controller.gon.search_applied_filter_values = nil
      controller.send(:record_applied_filter_value, 'distance', 5) # verify it initializes the hash
      controller.send(:record_applied_filter_value, 'aroy', 'foo') # verify it adds to the hash
      controller.send(:record_applied_filter_value, 'aroy2', 'bar')
      expect(controller.gon.search_applied_filter_values['distance']).to eq(5)
      expect(controller.gon.search_applied_filter_values['aroy']).to eq('foo')
      expect(controller.gon.search_applied_filter_values['aroy2']).to eq('bar')
    end
  end
end
