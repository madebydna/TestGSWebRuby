# frozen_string_literal: true

require 'spec_helper'

describe 'New search page' do
  context 'with no solr results' do
    before do
      stub_request(:any, /\/main\/select/)
        .to_return(status: 200, body: {response: {docs: [], numFound: 0}}.to_json, headers: {})

      FactoryBot.create(:city, name: 'Alameda', state: 'ca')
      FactoryBot.create(:district_record, name: 'Alameda Unified School District', city: 'Alameda', state: 'ca')
    end

    after do
      do_clean_models(City, DistrictRecord)
    end

    [
      ['/search/search.page?q=foo', true],
      ['/search/search.page?lat=1&lon=2', true],
      ['/search/search.page?lat=1&lon=2&radius=3', true],
      ['/california/alameda/schools/', true],
      ['/california/alameda/schools/?q=bay', true],
      ['/california/alameda/alameda-unified-school-district/schools/?q=bay', true]
    ].each do |path, should_write_noindex|
      it "the uri: #{path} should #{should_write_noindex ? '' : 'not'} include noindex tag" do
        get path
        if should_write_noindex
          expect(response.body).to include('<meta name="robots" content="noindex" />')
        else
          expect(response.body).to_not include('<meta name="robots" content="noindex" />')
        end
      end
    end
  end

  context 'with two solr results' do
    before do
      stub_request(:any, /\/solr\/main\/select/)
          .to_return(status: 200, body: {response: {docs: [{school_value:20, school_id:1, school_database_state:['CA'], state:'CA', id:[1,2]},{school_value:14, school_id:1, school_database_state:['CA'], id:[1,2], state: 'CA'}], numFound: 2}}.to_json, headers: {})
      FactoryBot.create(:city, name: 'Alameda', state: 'ca')
      FactoryBot.create(:district_record, name: 'Alameda Unified School District', city: 'Alameda', state: 'ca')
      FactoryBot.create(:alameda_high_school, id: 1)
    end

    after do
      do_clean_models(City, DistrictRecord)
      clean_dbs(:ca)
    end

    [
        ['/search/search.page?q=foo', true],
        ['/search/search.page?lat=1&lon=2', true],
        ['/search/search.page?lat=1&lon=2&radius=3', true],
    ].each do |path, should_write_noindex|

      it "the uri: #{path} should #{should_write_noindex ? '' : 'not'} include noindex tag" do
        get path
        if should_write_noindex
          expect(response.body).to include('<meta name="robots" content="noindex" />')
        else
          expect(response.body).to_not include('<meta name="robots" content="noindex" />')
        end
      end
    end
  end
end
