require 'spec_helper'

describe 'School Search Service' do
  describe '.by_location' do

    let(:empty_result) { { 'response' => {'docs' => [] } } }

    it 'should pass offset options to get_results method' do
      expect(SchoolSearchService).to receive(:get_results) do |options|
        expect(options[:rows]).to eql(50)
        expect(options[:start]).to eql(25)
      end.and_return(empty_result)
      SchoolSearchService.by_location({:lat => 39.1001, :lon => -75.511, :number_of_results => 50, :offset => 25})
    end

    it 'does not error if provided lat and lon' do
      allow(SchoolSearchService).to receive(:get_results).and_return(empty_result)
      expect{SchoolSearchService.by_location({:lat => 39.1001, :lon => -75.511})}.not_to raise_error
    end
    it 'errors if not provided a lat' do
      expect{SchoolSearchService.by_location({:lon => -75.511})}.to raise_error ArgumentError, 'Latitude is required'
    end
    it 'errors if not provided a lon' do
      expect{SchoolSearchService.by_location({:lat => 39.1001})}.to raise_error ArgumentError, 'Longitude is required'
    end
    it 'errors if not provided a lat or lon' do
      expect{SchoolSearchService.by_location({})}.to raise_error ArgumentError, 'Latitude is required'
    end
  end

  describe '.city_browse' do

    let(:empty_result) { { 'response' => {'docs' => [] } } }

    it 'should pass offset options to get_results method' do
      expect(SchoolSearchService).to receive(:get_results) do |options|
        expect(options[:rows]).to eql(50)
        expect(options[:start]).to eql(25)
      end.and_return(empty_result)
      SchoolSearchService.city_browse({:state => 'de', :city => 'dover', :number_of_results => 50, :offset => 25})
    end

    it 'does not error if provided city and state' do
      allow(SchoolSearchService).to receive(:get_results).and_return(empty_result)
      expect{SchoolSearchService.city_browse({:state => 'de', :city => 'dover'})}.not_to raise_error
    end
    it 'errors if not provided a state' do
      expect{SchoolSearchService.city_browse({:city => 'dover'})}.to raise_error ArgumentError, 'State is required'
    end
    it 'errors if state is not an abbreviation' do
      expect{SchoolSearchService.city_browse({:state => 'California', :city => 'dover'})}.to raise_error ArgumentError, /abbreviation/
    end
    it 'errors if not provided a city' do
      expect{SchoolSearchService.city_browse({:state => 'de'})}.to raise_error ArgumentError, 'City is required'
    end
  end

  describe '.district_browse' do

    let(:empty_result) { { 'response' => {'docs' => [] } } }

    it 'should pass offset options to get_results method' do
      expect(SchoolSearchService).to receive(:get_results) do |options|
        expect(options[:rows]).to eql(50)
        expect(options[:start]).to eql(25)
      end.and_return(empty_result)
      SchoolSearchService.district_browse({:state => 'de', :district_id => 11, :number_of_results => 50, :offset => 25})
    end

    it 'does not error if provided district id and state' do
      allow(SchoolSearchService).to receive(:get_results).and_return(empty_result)
      expect{SchoolSearchService.district_browse({:state => 'de', :district_id => 11})}.not_to raise_error
    end
    it 'errors if not provided a state' do
      expect{SchoolSearchService.district_browse({:district_id => 11})}.to raise_error ArgumentError, 'State is required'
    end
    it 'errors if state is not an abbreviation' do
      expect{SchoolSearchService.district_browse({:state => 'California', :district_id => 11})}.to raise_error ArgumentError, /abbreviation/
    end
    it 'errors if not provided a district id' do
      expect{SchoolSearchService.district_browse({:state => 'de'})}.to raise_error ArgumentError, 'District id is required'
    end
  end

  describe '.by_name' do
    let(:empty_result) { { 'response' => {'docs' => [] } } }

    it 'should pass offset options to get_results method' do
      expect(SchoolSearchService).to receive(:get_results) do |options|
        expect(options[:rows]).to eql(50)
        expect(options[:start]).to eql(25)
      end.and_return(empty_result)
      SchoolSearchService.by_name({:state => 'de', :query => 'school name', :number_of_results => 50, :offset => 25})
    end

    it 'does not error if provided query string' do
      allow(SchoolSearchService).to receive(:get_results).and_return(empty_result)
      expect{SchoolSearchService.by_name({:query => 'school name'})}.not_to raise_error
    end
    it 'errors if not provided a query string' do
      expect{SchoolSearchService.by_name({})}.to raise_error ArgumentError, 'Query is required'
    end
    it 'errors if query string is entirely whitespace' do
      expect{SchoolSearchService.by_name({:query => '   '})}.to raise_error ArgumentError, 'Query is required'
      expect{SchoolSearchService.by_name({:query => " \t "})}.to raise_error ArgumentError, 'Query is required'
    end
    it 'errors if query string is empty' do
      expect{SchoolSearchService.by_name({:query => ''})}.to raise_error ArgumentError, 'Query must be at least one character'
    end
    it 'prepares query string before issuing query' do
      allow(SchoolSearchService).to receive(:prepare_query_string).and_return('roy school')
      allow(SchoolSearchService).to receive(:require_non_optional_words).and_return('+roy school')
      expect(SchoolSearchService).to receive(:get_results) do |options|
        expect(options[:query]).to eql('+roy school')
      end.and_return(empty_result)
      SchoolSearchService.by_name({:query => 'Roy School'})
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
    let(:sample_result) { {'database_state' => ['de', 'delaware']} }
    let(:out_of_order_result) { {'database_state' => ['maine', 'me']} }
    let(:invalid_result) { {'database_state' => ['roynation', 'ro']} }
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
        expect(hash[:sort]).to eql(value)
      end
    end
  end

  describe '.rename_keys' do
    let(:mapping_hash) { {anthony: :shomi, erik: :ines, marcelo: :lusine}}
    it 'renames keys preserving values' do
      hash = {:anthony => 'dev', :erik => 'pm', :marcelo => 'qa', :krusty => 'comedic relief'}
      SchoolSearchService.rename_keys(hash, mapping_hash)
      expect(hash).to include(:shomi => 'dev')
      expect(hash).to include(:ines => 'pm')
      expect(hash).to include(:lusine => 'qa')
      expect(hash).to include(:krusty => 'comedic relief')
      expect(hash).not_to include(:anthony)
      expect(hash).not_to include(:erik)
      expect(hash).not_to include(:marcelo)
    end
  end

  describe '.extract_filters' do
    describe 'handles school type' do
      let (:single_school_type) { {:filters => {:school_type => [:public] }} }
      let (:multiple_school_types) { {:filters => {:school_type => [:charter, :private] }} }
      let (:no_school_types) { {:filters => {:school_type => [] }} }
      it 'public' do
        rval = SchoolSearchService.extract_filters single_school_type
        expect(rval).to include('+school_type:(public)')
      end
      it 'charter and private' do
        rval = SchoolSearchService.extract_filters multiple_school_types
        expect(rval).to include('+school_type:(charter private)')
      end
      it 'when empty' do
        rval = SchoolSearchService.extract_filters no_school_types
        expect(rval).not_to include('+school_type:()')
      end
    end
    describe 'handles level code' do
      let (:single_level_code) { {:filters => {:level_code => [:elementary] }} }
      let (:multiple_level_codes) { {:filters => {:level_code => [:middle, :high] }} }
      let (:no_level_codes) { {:filters => {:level_code => [] }} }
      it 'elementary' do
        rval = SchoolSearchService.extract_filters single_level_code
        expect(rval).to include('+school_grade_level:(e)')
      end
      it 'middle and high' do
        rval = SchoolSearchService.extract_filters multiple_level_codes
        expect(rval).to include('+school_grade_level:(m h)')
      end
      it 'when empty' do
        rval = SchoolSearchService.extract_filters no_level_codes
        expect(rval).not_to include('+school_grade_level:()')
      end
    end
    describe 'handles grades' do
      let (:preschool) { {:filters => {:grades => [:grade_p] }} }
      let (:kindergarten) { {:filters => {:grades => [:grade_k] }} }
      let (:high_school) { {:filters => {:grades => [:grade_9, :grade_10, :grade_11, :grade_12] }} }
      let (:single_grade) { {:filters => {:grades => [:grade_1] }} }
      let (:multiple_grades) { {:filters => {:grades => [:grade_2, :grade_3] }} }
      let (:no_grades) { {:filters => {:grades => [] }} }
      it 'first grade' do
        rval = SchoolSearchService.extract_filters single_grade
        expect(rval).to include('+grades:(1)')
      end
      it 'preschool' do
        rval = SchoolSearchService.extract_filters preschool
        expect(rval).to include('+grades:(PK)')
      end
      it 'kindergarten' do
        rval = SchoolSearchService.extract_filters kindergarten
        expect(rval).to include('+grades:(KG)')
      end
      it 'high school' do
        rval = SchoolSearchService.extract_filters high_school
        expect(rval).to include('+grades:(9 10 11 12)')
      end
      it 'when empty' do
        rval = SchoolSearchService.extract_filters no_grades
        expect(rval).not_to include('+grades:()')
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