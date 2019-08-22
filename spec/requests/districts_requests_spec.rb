require 'spec_helper'

describe 'District home page requests' do
  before { stub_request(:post, /\/solr\/main/).to_return(status: 200, body: "{}", headers: {}) }

  def expect_redirect_to(path)
    expect(response.status).to eq(301)
    expect(response.headers['Location']).to eq("http://www.example.com#{path}")
  end

  describe 'In California' do
    before do
      FactoryBot.create(:district, name: 'San Francisco Unified', city: 'San Francisco')
      get test_url
    end

    after do
      clean_models(:ca, District)
    end

    describe 'With a correct path' do
      let(:test_url) { '/california/san-francisco/san-francisco-unified/' }
      subject { response.code }

      it { is_expected.to eq('200') }
    end

    describe 'With an unknown district name' do
      let(:test_url) { '/california/san-francisco/oakland-city-unified/' }

      it 'should redirect to city page' do
        expect_redirect_to('/california/san-francisco/')
      end
    end
  end

  describe 'In New Jersey' do
    before do
      # Note because of model sharding (and FactoryBot's obliviousness to it) to properly save a sharded FactoryBot
      # model to a database other than the default (:ca) this is what you need to do
      nj_district = FactoryBot.build(:district, name: 'Jersey City Unified', city: 'Jersey City', state: 'NJ')
      District.on_db(:nj) { nj_district.save }
      get test_url
    end

    after do
      clean_models(:nj, District)
    end

    describe 'With a correct path' do
      let(:test_url) { '/new-jersey/jersey-city/jersey-city-unified/' }
      subject { response.code }

      it { is_expected.to eq('200') }
    end

    describe 'With an unknown district name' do
      let(:test_url) { '/new-jersey/jersey-city/oakland-city-unified/' }

      it 'should redirect to city page' do
        expect_redirect_to('/new-jersey/jersey-city/')
      end
    end
  end
end
