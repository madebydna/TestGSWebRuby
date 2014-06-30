require 'spec_helper'

describe 'School Search Service' do
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

  describe '.remap_sort' do
    @cases = {
      rating_asc: 'sorted_gs_rating_asc asc',
      rating_desc: 'overall_gs_rating desc',
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
end