# frozen_string_literal: true

require 'spec_helper'

describe 'New search page' do
  context 'with no solr results' do
    before do
      stub_request(:any, /\/main\/select/)
        .to_return(status: 200, body: {response: {docs: [], numFound: 0}}.to_json, headers: {})

      FactoryGirl.create(:city, name: 'Alameda', state: 'ca')
      FactoryGirl.create(:district, name: 'Alameda Unified School District', city: 'Alameda', state: 'ca')
    end

    after do
      clean_models(City, District)
    end

    [
      ['/search/search.page?newsearch&q=foo', true],
      ['/search/search.page?newsearch&lat=1&lon=2', true],
      ['/search/search.page?newsearch&lat=1&lon=2&radius=3', true],
      ['/california/alameda/schools/?newsearch', true],
      ['/california/alameda/schools/?newsearch&q=bay', true],
      ['/california/alameda/alameda-unified-school-district/schools/?newsearch&q=bay', true]
    ].each do |path, should_write_noindex|
      it "the uri: #{path} should #{should_write_noindex ? '' : 'not'} include noindex tag" do
        get path
        expect(response.status).to eq(200)
        if should_write_noindex
          expect(response.body).to include('<meta name="robots" content="noindex, nofollow" />')
        else
          expect(response.body).to_not include('<meta name="robots" content="noindex, nofollow" />')
        end
      end
    end
  end
  context 'with two solr results' do
    before do
      stub_request(:any, /\/main\/select/)
          .to_return(status: 200, body: {response: {docs: [{school_value:20, school_id:1, school_database_state:['AK', 'CA']},{school_value:14, school_id:1, school_database_state:['AK', 'CA']}], numFound: 2}}.to_json, headers: {})

      FactoryGirl.create(:city, name: 'Alameda', state: 'ca')
      FactoryGirl.create(:district, name: 'Alameda Unified School District', city: 'Alameda', state: 'ca')
    end

    after do
      clean_models(City, District)
    end

    [
        ['/search/search.page?newsearch&q=foo', true],
        ['/search/search.page?newsearch&lat=1&lon=2', true],
        ['/search/search.page?newsearch&lat=1&lon=2&radius=3', true],
        # ['/california/alameda/schools/?newsearch', false],
        # ['/california/alameda/schools/?newsearch&q=bay', false],
        # ['/california/alameda/alameda-unified-school-district/schools/?newsearch&q=bay', false]
    ].each do |path, should_write_noindex|

      it "the uri: #{path} should #{should_write_noindex ? '' : 'not'} include noindex tag" do
        get path
        expect(response.status).to eq(200)
        if should_write_noindex
          expect(response.body).to include('<meta name="robots" content="noindex, nofollow" />')
        else
          expect(response.body).to_not include('<meta name="robots" content="noindex, nofollow" />')
        end
      end
    end
  end
end