require 'spec_helper'
require 'controllers/contexts/ad_shared_contexts'
require 'controllers/examples/ad_shared_examples'

describe SearchController do
  [PaginationConcerns, GoogleMapConcerns, SearchMetaTagsConcerns, HubConcerns].each do | mod |
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

  describe '#search' do
    subject {get :search, params_hash}
    context 'when only lat and lon params present' do
      let (:params_hash) { {lat: '1', lon: '1'} }
      before { expect(controller).not_to receive(:by_location) }
      it { expect(subject).to redirect_to(default_search_url) }
    end

    context 'when q is blank and state is present' do
      let (:params_hash) { {state: 'CA', q: ''} }
      before { expect(controller).not_to receive(:by_name) }
      it { expect(subject).to redirect_to(default_search_url) }
    end

    context 'when no query parameters are specified' do
      let (:params_hash) { {} }
      before { expect(controller).not_to receive(:by_name) }
      it { expect(subject).to redirect_to(default_search_url) }
    end

    context 'when the q parameter is blank' do
      let (:params_hash) { {q: ''} }
      before { expect(controller).not_to receive(:by_name) }
      it { expect(subject).to redirect_to(default_search_url) }
    end

    context 'when query parameter and state is specified' do
      let (:params_hash) { {q: 'query', state: 'ca'} }
      it 'should render the search results page' do
        allow(SchoolSearchService).to receive(:by_name).and_return(results: [], num_found: 0)
        expect(subject).to render_template 'search_page'
      end
    end

    context 'when given an invalid UTF-8 byte sequence' do
      let (:params_hash) { {q: "here comes a really bad character: \xF4"}}
      it 'redirects and subs out the bad characters' do
        expect(subject.status).to eq(302)
      end
    end
  end

  describe '#process_results' do
    let (:results) { {num_found: 0, results: []}}
    before do
      controller.instance_variable_set(:@params_hash, {})
      controller.instance_variable_set(:@results_offset, 0)
      controller.instance_variable_set(:@page_size, 25)
    end
    it 'JT-927 regression: does not crash when map_schools is empty' do
      # Crash occurred when results was empty and calculate_map_range returned a non-zero range
      allow(controller).to receive(:calculate_map_range) { [1, 2] }
      controller.process_results(results, 0)
      expect(controller.instance_variable_get(:@map_schools)).not_to be_nil
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

    context 'When there is overall rating in filter params' do
      gs_rating_allows = Proc.new {
        allow(controller).to receive(:should_apply_filter?).and_return(false)
        allow(controller).to receive(:should_apply_filter?).with(:gs_rating).and_return(true)
      }

      context 'with only above_average filter' do
        let(:params_hash) { {'gs_rating' => 'above_average'} }

        it 'should set the filter to be 8 to 10' do
          instance_exec &gs_rating_allows
          filters = controller.send(:parse_filters, params_hash)
          expect(filters).to eq({:overall_gs_rating=>[8, 9, 10]})
        end
      end

      context 'with all three rating filters' do
        let(:params_hash) { {'gs_rating' => ['above_average','average','below_average']} }

        it 'Should set the filter to be 1 to 10 so that it does not include NR' do
          instance_exec &gs_rating_allows
          filters = controller.send(:parse_filters, params_hash)
          expect(filters).to have_key(:overall_gs_rating)
          (1..10).each {|rating| expect(filters[:overall_gs_rating]).to include(rating)}
        end
      end
    end

    context 'When there is path to quality rating in filter params' do
      path_to_quality_rating_allows = Proc.new {
        allow(controller).to receive(:should_apply_filter?).and_return(false)
        allow(controller).to receive(:should_apply_filter?).with(:ptq_rating).and_return(true)
      }

      context 'with a few ratings' do
        let(:params_hash) { {'ptq_rating' => ['level_2','level_3']} }
        it "should set the right filter for ratings" do
          instance_exec &path_to_quality_rating_allows
          filters = controller.send(:parse_filters, params_hash)
          expect(filters).to eq({:ptq_rating=>['Level 2','Level 3']})
        end
      end

      context 'with a all ratings' do
        let(:params_hash) { {'ptq_rating' => ['level_1','level_2','level_3','level_4']} }
        it "should set all 4 ratings filters, so that only schools with ratings are displayed" do
          instance_exec &path_to_quality_rating_allows
          filters = controller.send(:parse_filters, params_hash)
          expect(filters).to eq({:ptq_rating=>["Level 1", "Level 2", "Level 3", "Level 4"]})
        end
      end
    end

    context 'When there is great start to quality rating in filter params' do
      gstq_rating_allows = Proc.new {
        allow(controller).to receive(:should_apply_filter?).and_return(false)
        allow(controller).to receive(:should_apply_filter?).with(:gstq_rating).and_return(true)
      }

      context 'with one rating' do
        let(:params_hash) { {'gstq_rating' => '5'} }
        it "should set the right filter for ratings" do
          instance_exec &gstq_rating_allows
          filters = controller.send(:parse_filters, params_hash)
          expect(filters).to eq({:gstq_rating=> ['5']})
        end
      end

      context 'with a few ratings' do
        let(:params_hash) { {'gstq_rating' => %w(4 5)} }
        it "should set the right filters for ratings" do
          instance_exec &gstq_rating_allows
          filters = controller.send(:parse_filters, params_hash)
          expect(filters).to eq({:gstq_rating=> %w(4 5)})
        end
      end

      context 'with all ratings' do
        let(:params_hash) { {'gstq_rating' => %w(1 2 3 4 5)} }
        it "should set all 5 ratings filters" do
          instance_exec &gstq_rating_allows
          filters = controller.send(:parse_filters, params_hash)
          expect(filters).to eq({:gstq_rating=> %w(1 2 3 4 5)})
        end
      end
    end

  end

  context 'When there is colorado_rating in filter params' do
    before do
      allow(controller).to receive(:should_apply_filter?).and_return(false)
      allow(controller).to receive(:should_apply_filter?).
        with(:colorado_rating).and_return(true)
    end

    context 'with a few ratings' do
      let(:params_hash) do
        {'colorado_rating' => ['colorado_1','colorado_2']}
      end
      it "should set the right filter for ratings" do
        filters = controller.send(:parse_filters, params_hash)
        expect(filters).to eq(colorado_rating: ['Colorado 1','Colorado 2'])
      end
    end

    context 'with a all ratings' do
      let(:params_hash) do
        {'colorado_rating' => ['colorado_1','colorado_2','colorado_3','colorado_4']}
      end
      it "should set all 4 ratings filters, so that only schools with ratings are displayed" do
        filters = controller.send(:parse_filters, params_hash)
        expect(filters).to eq(
          colorado_rating: ["Colorado 1", "Colorado 2", "Colorado 3", "Colorado 4"]
        )
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
        expect(subject['county']).to be_nil
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
        expect(subject['county']).to eq('county')
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
    context 'when searching near a zip code by location' do
      before { controller.params.merge!(zipCode: '94111') }
      it 'should pass zip code through as a targeting attribute' do
        expect(subject['Zipcode']).to eq('94111')
      end
    end
    it 'should not set zip code on browse' do
      expect(subject['Zipcode']).to be_nil
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

  describe '#set_cache_headers_for_suggest' do
    let(:cache_time) { 12345 }
    it 'should call expires_in with public: true' do
      expect(controller).to receive(:expires_in).with(anything, {public: true})
      controller.set_cache_headers_for_suggest
    end
    it 'should get cache time from environment variable' do
      allow(ENV_GLOBAL).to receive(:[]).and_return(cache_time)
      expect(controller).to receive(:expires_in).with(cache_time, anything)
      controller.set_cache_headers_for_suggest
    end
  end

  [:city, :school, :district].each do | search_type |
    describe "XHR GET suggest_#{search_type}_by_name" do
      let(:cache_time) { 12345 }
      let(:env_global) { ENV_GLOBAL.to_hash.merge({'search_suggest_cache_time' => cache_time}) }
      let(:action) { "suggest_#{search_type}_by_name".to_sym }

      before { pending('Made pending because dependency on solr'); fail }
      it 'should have cache-control headers set to public and a configured time' do
        stub_const('ENV_GLOBAL', env_global)
        xhr :get, action, state: 'de', query: 's'
        expect(response.header).to include({'Cache-Control' => "max-age=#{cache_time}, public"})
      end

      it 'should not have \'Vary\' headers' do
        stub_const('ENV_GLOBAL', env_global)
        xhr :get, action, state: 'de', query: 's'
        expect(response.header).to_not include({'Vary' => anything})
      end
    end
  end

  describe '#add_filters_to_gtm_data_layer' do
    context 'The dimension "GS Search Filters Used"' do
      it 'should handle no variable set' do
        controller.send(:add_filters_to_gtm_data_layer)
        expect(controller.instance_variable_get('@data_layer_gon_hash')['GS Search Filters Used']).to eq('No')
      end
      it 'should handle no filters set' do
        controller.instance_variable_set(:@filter_values, [])
        controller.send(:add_filters_to_gtm_data_layer)
        expect(controller.instance_variable_get('@data_layer_gon_hash')['GS Search Filters Used']).to eq('No')
      end
      it 'should ignore the default 5 miles filter' do
        controller.instance_variable_set(:@filter_values, ['5_miles'])
        controller.send(:add_filters_to_gtm_data_layer)
        expect(controller.instance_variable_get('@data_layer_gon_hash')['GS Search Filters Used']).to eq('No')
      end
      it 'should include filter values' do
        controller.instance_variable_set(:@filter_values, ['boys_basketball'])
        controller.send(:add_filters_to_gtm_data_layer)
        expect(controller.instance_variable_get('@data_layer_gon_hash')['GS Search Filters Used']).to eq('Yes')
      end
      it 'should include filter values if there are others besides the default 5 miles' do
        controller.instance_variable_set(:@filter_values, %w(5_miles boys_basketball))
        controller.send(:add_filters_to_gtm_data_layer)
        expect(controller.instance_variable_get('@data_layer_gon_hash')['GS Search Filters Used']).to eq('Yes')
      end
    end
    context 'The dimension "GS Search Filters Applied"' do
      it 'should list filter values with a trailing space' do
        # the trailing space allows Google Analytics admins to run queries on it
        controller.instance_variable_set(:@filter_values, %w(before_care boys_basketball))
        controller.send(:add_filters_to_gtm_data_layer)
        expect(controller.instance_variable_get('@data_layer_gon_hash')['GS Search Filters Applied']).to eq('before_care boys_basketball ')
      end
      it 'should include the default 5_miles' do
        controller.instance_variable_set(:@filter_values, %w(5_miles))
        controller.send(:add_filters_to_gtm_data_layer)
        expect(controller.instance_variable_get('@data_layer_gon_hash')['GS Search Filters Applied']).to eq('5_miles ')
      end
      it 'should not be defined if there are no filters' do
        controller.instance_variable_set(:@filter_values, [])
        controller.send(:add_filters_to_gtm_data_layer)
        expect(controller.instance_variable_get('@data_layer_gon_hash')['GS Search Filters Applied']).to be_nil
      end
    end
  end
end
