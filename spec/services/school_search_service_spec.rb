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

    # it 'sorts results' do
    #   expect(SchoolSearchService).to receive(:get_results) do |options|
    #     expect(options[:sort]).to eql('overall_gs_rating asc')
    #   end.and_return(empty_result)
    #   SchoolSearchService.city_browse({:state => 'de', :city => 'dover', :sort => :rating_asc})
    # end

    it 'does not error if provided city and state' do
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

  describe '.remap_sort' do
    @cases = {
      rating_asc: 'overall_gs_rating asc',
      rating_desc: 'overall_gs_rating desc'
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