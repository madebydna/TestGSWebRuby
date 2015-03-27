require 'spec_helper'

describe 'School Search Service' do
  describe '.by_location' do

    let(:empty_result) { { 'response' => {'docs' => [] } } }

    it 'should pass offset options to get_results method' do
      expect(SchoolSearchService).to receive(:get_results) do |options|
        expect(options[:rows]).to eq(50)
        expect(options[:start]).to eq(25)
      end.and_return(empty_result)
      SchoolSearchService.by_location(lat: 39.1001, lon: -75.511, number_of_results: 50, offset: 25)
    end

    it 'does not error if provided lat and lon' do
      allow(SchoolSearchService).to receive(:get_results).and_return(empty_result)
      expect{SchoolSearchService.by_location(lat: 39.1001, lon: -75.511)}.not_to raise_error
    end
    it 'errors if not provided a lat' do
      expect{SchoolSearchService.by_location(lon: -75.511)}.to raise_error ArgumentError, 'Latitude is required'
    end
    it 'errors if not provided a lon' do
      expect{SchoolSearchService.by_location(lat: 39.1001)}.to raise_error ArgumentError, 'Longitude is required'
    end
    it 'errors if not provided a lat or lon' do
      expect{SchoolSearchService.by_location}.to raise_error ArgumentError, 'Latitude is required'
    end
  end

  describe '.city_browse' do

    let(:empty_result) { { 'response' => {'docs' => [] } } }

    it 'should pass offset options to get_results method' do
      expect(SchoolSearchService).to receive(:get_results) do |options|
        expect(options[:rows]).to eq(50)
        expect(options[:start]).to eq(25)
      end.and_return(empty_result)
      SchoolSearchService.city_browse(state: 'de', city: 'dover', number_of_results: 50, offset: 25)
    end

    it 'does not error if provided city and state' do
      allow(SchoolSearchService).to receive(:get_results).and_return(empty_result)
      expect{SchoolSearchService.city_browse(state: 'de', city: 'dover')}.not_to raise_error
    end
    it 'errors if not provided a state' do
      expect{SchoolSearchService.city_browse(city: 'dover')}.to raise_error ArgumentError, 'State is required'
    end
    it 'errors if state is not an abbreviation' do
      expect{SchoolSearchService.city_browse(state: 'California', city: 'dover')}.to raise_error ArgumentError, /abbreviation/
    end
    it 'errors if not provided a city' do
      expect{SchoolSearchService.city_browse(state: 'de')}.to raise_error ArgumentError, 'City is required'
    end
    it 'should have citykeyword' do
      expect(SchoolSearchService).to receive(:get_results) do |options|
        expect(options[:fq]).to include('+citykeyword:"indianapolis"')
      end.and_return(empty_result)
      SchoolSearchService.city_browse(state: 'in', city: 'indianapolis')
    end
    it 'should have school_database_state' do
      expect(SchoolSearchService).to receive(:get_results) do |options|
        expect(options[:fq]).to include('+school_database_state:"in"')
      end.and_return(empty_result)
      SchoolSearchService.city_browse(state: 'in', city: 'indianapolis')
    end
    describe 'when filtering by collection_id' do
      it 'should have collection_id in filters' do
        expect(SchoolSearchService).to receive(:get_results) do |options|
          expect(options[:fq]).to include('+collection_id:3')
        end.and_return(empty_result)
        SchoolSearchService.city_browse(state: 'in', city: 'indianapolis', filters:{collection_id:3})
      end
      it 'should not have citykeyword in filters' do
        expect(SchoolSearchService).to receive(:get_results) do |options|
          expect(options[:fq]).not_to include('+citykeyword:"indianapolis"')
        end.and_return(empty_result)
        SchoolSearchService.city_browse(state: 'in', city: 'indianapolis', filters:{collection_id:3})
      end
    end
  end

  describe '.district_browse' do

    let(:empty_result) { { 'response' => {'docs' => [] } } }

    it 'should pass offset options to get_results method' do
      expect(SchoolSearchService).to receive(:get_results) do |options|
        expect(options[:rows]).to eq(50)
        expect(options[:start]).to eq(25)
      end.and_return(empty_result)
      SchoolSearchService.district_browse(state: 'de', district_id: 11, number_of_results: 50, offset: 25)
    end

    it 'does not error if provided district id and state' do
      allow(SchoolSearchService).to receive(:get_results).and_return(empty_result)
      expect{SchoolSearchService.district_browse(state: 'de', district_id: 11)}.not_to raise_error
    end
    it 'errors if not provided a state' do
      expect{SchoolSearchService.district_browse(district_id: 11)}.to raise_error ArgumentError, 'State is required'
    end
    it 'errors if state is not an abbreviation' do
      expect{SchoolSearchService.district_browse(state: 'California', district_id: 11)}.to raise_error ArgumentError, /abbreviation/
    end
    it 'errors if not provided a district id' do
      expect{SchoolSearchService.district_browse(state: 'de')}.to raise_error ArgumentError, 'District id is required'
    end

    it 'should have school_district_id' do
      expect(SchoolSearchService).to receive(:get_results) do |options|
        expect(options[:fq]).to include('+school_district_id:"11"')
      end.and_return(empty_result)
      SchoolSearchService.district_browse(state: 'de', district_id: 11)
    end
    it 'should have school_database_state' do
      expect(SchoolSearchService).to receive(:get_results) do |options|
        expect(options[:fq]).to include('+school_database_state:"de"')
      end.and_return(empty_result)
      SchoolSearchService.district_browse(state: 'de', district_id: 11)
    end
    describe 'when filtering by collection_id' do
      it 'should have collection_id in filters' do
        expect(SchoolSearchService).to receive(:get_results) do |options|
          expect(options[:fq]).to include('+collection_id:3')
        end.and_return(empty_result)
        SchoolSearchService.district_browse(state: 'de', district_id: 11, filters:{collection_id:3})
      end
      it 'should not have school_district_id in filters' do
        expect(SchoolSearchService).to receive(:get_results) do |options|
          expect(options[:fq]).not_to include('+school_district_id:"11"')
        end.and_return(empty_result)
        SchoolSearchService.district_browse(state: 'de', district_id: 11, filters:{collection_id:3})
      end
    end
  end

  describe '.by_name' do
    let(:empty_result) { { 'response' => {'docs' => [] } } }

    it 'should pass offset options to get_results method' do
      expect(SchoolSearchService).to receive(:get_results) do |options|
        expect(options[:rows]).to eq(50)
        expect(options[:start]).to eq(25)
      end.and_return(empty_result)
      SchoolSearchService.by_name(state: 'de', query: 'school name', number_of_results: 50, offset: 25)
    end

    it 'does not error if provided query string' do
      allow(SchoolSearchService).to receive(:get_results).and_return(empty_result)
      expect{SchoolSearchService.by_name(query: 'school name')}.not_to raise_error
    end
    it 'errors if not provided a query string' do
      expect(SchoolSearchService.by_name).to be_empty
    end
    it 'errors if query string is entirely whitespace' do
      expect(SchoolSearchService.by_name(query: '   ')).to be_empty
      expect(SchoolSearchService.by_name(query: " \t ")).to be_empty
    end
    it 'errors if query string is empty' do
      expect(SchoolSearchService.by_name(query: '')).to be_empty
    end
    it 'prepares query string before issuing query' do
      allow(SchoolSearchService).to receive(:prepare_query_string).and_return('roy school')
      allow(SchoolSearchService).to receive(:require_non_optional_words).and_return('+roy school')
      expect(SchoolSearchService).to receive(:get_results) do |options|
        expect(options[:query]).to eq('+roy school')
      end.and_return(empty_result)
      SchoolSearchService.by_name(query: 'Roy School')
    end
    it 'filters by collection_id when asked' do
      expect(SchoolSearchService).to receive(:get_results) do |options|
        expect(options[:fq]).to include('+collection_id:3')
      end.and_return(empty_result)
      SchoolSearchService.by_name(state: 'de', query: 'school name', filters:{collection_id:3})
    end
  end

  describe '.add_level_codes' do
    let (:hash) { {} }
    it 'should handle nil gracefully' do
      SchoolSearchService.add_level_codes(hash, nil)
      expect(hash['level_code']).to eq('')
      expect(hash['level_codes']).to be_empty
    end
    it 'should handle handle basic level codes regardless of order' do
      SchoolSearchService.add_level_codes(hash, %w(e m h p))
      expect(hash['level_code']).to eq('p,e,m,h')
      expect(hash['level_codes']).to include('p')
      expect(hash['level_codes']).to include('e')
      expect(hash['level_codes']).to include('m')
      expect(hash['level_codes']).to include('h')
    end
    it 'should ignore words and just match on level codes' do
      SchoolSearchService.add_level_codes(hash, %w(e elementary))
      expect(hash['level_code']).to eq('e')
      expect(hash['level_codes']).to include('e')
      expect(hash['level_codes']).not_to include('elementary')
      expect(hash['level_codes']).not_to include('m')
      expect(hash['level_codes']).not_to include('h')
      expect(hash['level_codes']).not_to include('p')
    end
    it 'should ignore invalid level codes' do
      SchoolSearchService.add_level_codes(hash, %w(q r x))
      expect(hash['level_code']).to eq('')
      expect(hash['level_codes']).not_to include('q')
      expect(hash['level_codes']).not_to include('r')
      expect(hash['level_codes']).not_to include('x')
    end
  end

  describe '.get_state_abbreviation' do
    let(:sample_result) { {'school_database_state' => ['de', 'delaware']} }
    let(:out_of_order_result) { {'school_database_state' => ['maine', 'me']} }
    let(:invalid_result) { {'school_database_state' => ['roynation', 'ro']} }
    it 'should handle nil gracefully' do
      expect(SchoolSearchService.get_state_abbreviation({})).to be_nil
    end
    it 'should pull two letter abbrevation' do
      expect(SchoolSearchService.get_state_abbreviation(sample_result)).to eq('de')
    end
    it 'should pull two letter abbrevation ignoring order' do
      expect(SchoolSearchService.get_state_abbreviation(out_of_order_result)).to eq('me')
    end
    it 'should ignore invalid state abbreviations' do
      expect(SchoolSearchService.get_state_abbreviation(invalid_result)).to be_nil
    end
  end

  describe '.remap_sort' do
    @cases = {
      rating_asc: 'sorted_gs_rating_asc asc',
      rating_desc: 'overall_gs_rating desc',
      distance_asc: 'distance asc',
      distance_desc: 'distance desc',
      name_asc: 'school_name asc',
      name_desc: 'school_name desc'
    }
    @cases.each do | key, value |
      it "should replace #{key} with #{value}" do
        hash = {sort: key}
        SchoolSearchService.remap_sort(hash)
        expect(hash[:sort]).to eq(value)
      end
    end
  end

  describe '.rename_keys' do
    let(:mapping_hash) { {anthony: :shomi, erik: :ines, marcelo: :lusine}}
    it 'renames keys preserving values' do
      hash = {anthony: 'dev', erik: 'pm', marcelo: 'qa', krusty: 'comedic relief'}
      SchoolSearchService.rename_keys(hash, mapping_hash)
      expect(hash).to include(shomi: 'dev')
      expect(hash).to include(ines: 'pm')
      expect(hash).to include(lusine: 'qa')
      expect(hash).to include(krusty: 'comedic relief')
      expect(hash).not_to include(:anthony)
      expect(hash).not_to include(:erik)
      expect(hash).not_to include(:marcelo)
    end
  end

  describe '.extract_hard_filters' do
    describe 'handles school type' do
      @valid_school_types = [:public, :charter, :private]
      (1..3).each do |i|
        @valid_school_types.combination(i) do |st|
          it "#{st.join(',')}" do
            filter_hash = {filters: {school_type: st}}
            expect(SchoolSearchService.extract_hard_filters(filter_hash)).to include("+school_type:(#{st.join(' ')})")
          end
        end
      end
      let (:no_school_types) { {filters: {school_type: [] }} }
      let (:invalid_school_types) { {filters: {school_type: [:district, :montessori] }} }
      let (:invalid_and_valid) { {filters: {school_type: [:district, :public, :montessori] }} }
      it 'invalid mixed with valid' do
        rval = SchoolSearchService.extract_hard_filters invalid_and_valid
        expect(rval).to include('+school_type:(public)')
      end
      it 'invalid' do
        rval = SchoolSearchService.extract_hard_filters invalid_school_types
        expect(rval).not_to include('+school_type:()')
      end
      it 'when empty' do
        rval = SchoolSearchService.extract_hard_filters no_school_types
        expect(rval).not_to include('+school_type:()')
      end
    end
    describe 'handles level code' do
      @valid_level_codes = [:preschool, :elementary, :middle, :high]
      (1..4).each do |i|
        @valid_level_codes.combination(i) do |lc|
          it "#{lc.join(',')}" do
            lc_space_separated = lc.collect {|fullname| fullname[0]}.join(' ')
            filter_hash = {filters: {level_code: lc}}
            expect(SchoolSearchService.extract_hard_filters(filter_hash)).to include("+school_grade_level:(#{lc_space_separated})")
          end
        end
      end
      let (:invalid_level_codes) { {filters: {level_code: [:morning, :afternoon, :evening, :night] }} }
      let (:invalid_and_valid) { {filters: {level_code: [:morning, :elementary, :afternoon, :middle] }} }
      let (:no_level_codes) { {filters: {level_code: [] }} }
      it 'invalid mixed with valid' do
        rval = SchoolSearchService.extract_hard_filters invalid_and_valid
        expect(rval).to include('+school_grade_level:(e m)')
      end
      it 'invalid' do
        rval = SchoolSearchService.extract_hard_filters invalid_level_codes
        expect(rval).not_to include('+school_grade_level:()')
      end
      it 'when empty' do
        rval = SchoolSearchService.extract_hard_filters no_level_codes
        expect(rval).not_to include('+school_grade_level:()')
      end
    end
    describe 'handles grades' do
      let (:preschool) { {filters: {grades: [:grade_p] }} }
      let (:kindergarten) { {filters: {grades: [:grade_k] }} }
      let (:high_school) { {filters: {grades: [:grade_9, :grade_10, :grade_11, :grade_12] }} }
      let (:non_contiguous_range) { {filters: {grades: [:grade_k, :grade_1, :grade_2, :grade_3, :grade_7, :grade_8, :grade_11, :grade_12] }} }
      let (:first_grade) { {filters: {grades: [:grade_1] }} }
      let (:invalid_grades) { {filters: {grades: [:first, :second, :preschool] }} }
      let (:invalid_and_valid) { {filters: {grades: [:first, :second, :grade_3, :preschool, :grade_4] }} }
      let (:no_grades) { {filters: {grades: [] }} }
      it 'first grade' do
        rval = SchoolSearchService.extract_hard_filters first_grade
        expect(rval).to include('+grades:(1)')
      end
      it 'preschool' do
        rval = SchoolSearchService.extract_hard_filters preschool
        expect(rval).to include('+grades:(PK)')
      end
      it 'kindergarten' do
        rval = SchoolSearchService.extract_hard_filters kindergarten
        expect(rval).to include('+grades:(KG)')
      end
      it 'high school' do
        rval = SchoolSearchService.extract_hard_filters high_school
        expect(rval).to include('+grades:(9 10 11 12)')
      end
      it 'non-contiguous range' do
        rval = SchoolSearchService.extract_hard_filters non_contiguous_range
        expect(rval).to include('+grades:(KG 1 2 3 7 8 11 12)')
      end
      it 'invalid grades' do
        rval = SchoolSearchService.extract_hard_filters invalid_grades
        expect(rval).not_to include('+grades:()')
      end
      it 'invalid grades mixed with valid' do
        rval = SchoolSearchService.extract_hard_filters invalid_and_valid
        expect(rval).to include('+grades:(3 4)')
      end
      it 'when empty' do
        rval = SchoolSearchService.extract_hard_filters no_grades
        expect(rval).not_to include('+grades:()')
      end
    end
    describe 'handles school_college_going_rate' do
      valid_college_going_rate = '70 TO 100'
      it 'accepts the valid college going rate value' do
        filter_hash = {filters: {school_college_going_rate: valid_college_going_rate}}
        expect(SchoolSearchService.extract_hard_filters(filter_hash)).to include("+school_college_going_rate:[#{valid_college_going_rate}]")
      end

      let (:invalid_college_going_rate) { {filters: {school_college_going_rate: :blue }} }
      let (:no_college_going_rate) { {filters: {}} }
      it 'rejects invalid rates' do
        rval = SchoolSearchService.extract_hard_filters invalid_college_going_rate
        expect(rval).to_not include('+school_college_going_rate:[blue]')
      end
      it 'rejects empty values' do
        rval = SchoolSearchService.extract_hard_filters no_college_going_rate
        expect(rval).to_not include('+school_college_going_rate:')
      end
    end

    describe 'handles overall GS rating' do
      let (:above_average) { {filters: {overall_gs_rating: [8,9,10] }} }
      it 'should include the overall rating filters' do
        rval = SchoolSearchService.extract_hard_filters above_average
        expect(rval).to include('+overall_gs_rating:(8 9 10)')
      end
    end

    describe 'handles path to progress rating' do
      let (:level_2) { {filters: {ptq_rating: ['Level 2', 'Level 3'] }} }
      it 'should include the path to progress rating filters' do
        rval = SchoolSearchService.extract_hard_filters level_2
        expect(rval).to include('+path_to_quality_rating:("Level 2" "Level 3")')
      end
    end
  end

  describe '.extract_by_location' do
    let(:valid_hash) { {lat:1.0, lon:2.0, radius:10.0} }
    let(:valid_hash_no_radius) { {lat:1.0, lon:2.0} }
    it 'produces the correct geospatial plugin syntax' do
      expect(SchoolSearchService.extract_by_location(valid_hash)).to eq('{!spatial circles=1.0,2.0,16.0}')
    end
    it 'uses 5 miles as the default radius' do
      expect(SchoolSearchService.extract_by_location(valid_hash_no_radius)).to eq('{!spatial circles=1.0,2.0,8.0}')
    end
    it 'requires lat and lon to be present' do
      expect(SchoolSearchService.extract_by_location({radius:10.0})).to eq('')
      expect(SchoolSearchService.extract_by_location({lat:1.0, radius:10.0})).to eq('')
      expect(SchoolSearchService.extract_by_location({lon:2.0, radius:10.0})).to eq('')
    end
  end
end