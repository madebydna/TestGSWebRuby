require 'spec_helper'

describe "Schools API" do
  after do
    clean_dbs :gs_schooldb, :ca, :us_geo
  end

  before { stub_request(:post, /\/solr\/main\/select/).to_return(status: 200, body: "{}", headers: {}) }

  before(:all) do
    head '/'
    @csrf_token = request.cookie_jar.fetch(:csrf_token)
  end

  def get(path, hash={})
    super(path, hash, { 'X-CSRF-Token' => @csrf_token })
  end

  let(:json) { JSON.parse(response.body) }
  let(:status) { response.status }
  let(:errors) { json['errors'] }

  describe 'show' do
    it 'Returns school 1 by ID' do
      s1 = create_school(:alameda_high_school)
      create_school(:bay_farm_elementary_school)

      get "/gsr/api/schools/#{s1.id}?state=ca"
      expect(status).to eq(200)
      expect(errors).to be_blank
      expect(json).to be_present
      expect(json['name']).to eq(s1.name)
    end

    it 'Contains a link to school profile' do
      s1 = create_school(:alameda_high_school)

      get "/gsr/api/schools/#{s1.id}?state=ca"
      expect(status).to eq(200)
      expect(errors).to be_blank
      expect(json).to be_present
      expect(json['links']).to be_present
      expect(json['links']['profile']).to be_present
    end

    it 'Returns school 2 by ID' do
      create_school(:alameda_high_school)
      s2 = create_school(:bay_farm_elementary_school)

      get "/gsr/api/schools/#{s2.id}?state=ca"
      expect(status).to eq(200)
      expect(errors).to be_blank
      expect(json).to be_present
      expect(json['name']).to eq(s2.name)
    end

    it 'Requires a state' do
      get '/gsr/api/schools/', format: :json
      expect(status).to be(404)
      expect(errors).to be_present
    end

    it 'does not return inactive school' do
      s = create_school(:alameda_high_school, active: false)
      get "/gsr/api/schools/#{s.id}?state=#{s.state}", format: :json
      expect(status).to eq(200)
      expect(errors).to be_blank
      expect(json).to be_blank
    end

    it 'Returns a successful (empty) response if ID not found' do
      get "/gsr/api/schools/1?state=ca"
      expect(status).to eq(200)
      expect(errors).to be_blank
      expect(json).to be_blank
    end

    context 'with geometry data available for school' do
      let(:school) { create_school(:alameda_high_school) }
      before do
        str = 'MULTIPOLYGON(((1 1,1 10,10 10,10 1,1 1)))'
        create_geo_data(str)
        stub_solr_schools(school)
      end
      let(:coordinates) do
        [[[
          [1, 1],
          [1, 10],
          [10, 10],
          [10, 1],
          [1, 1]
        ]]]
      end

      it 'Doesnt include geometry by default' do
        get "/gsr/api/schools/#{school.id}?state=ca"
        expect(status).to eq(200)
        expect(errors).to be_blank
        expect(json).to be_present
        expect(json['boundaries']).to_not be_present
      end

      it 'Returns boundary data when asked' do
        get "/gsr/api/schools/#{school.id}?state=ca&extras=boundaries"
        expect(status).to eq(200)
        expect(errors).to be_blank
        expect(json).to be_present
        expect(json['boundaries']).to be_present
        expect(json['boundaries']['o']).to be_present
        expect(json['boundaries']['o']['coordinates']).to eq(coordinates)
      end
    end
  end

  describe 'index' do
    let(:schools) { json['items'] }

    it 'Requires a state when location unknown' do
      get '/gsr/api/schools/', format: :json
      expect(status).to be(404)
      expect(errors).to be_present
    end

    it "Doesn't require a state when lat/lon provided" do
      stub_solr_schools(create_school(:alameda_high_school))
      get '/gsr/api/schools/?lat=1&lon=1&extras=boundaries', format: :json
      expect(status).to be(200)
      expect(errors).to be_blank
    end

    it 'Returns some schools' do
      count = 2
      stub_solr_schools(
        create_school(:alameda_high_school),
        create_school(:bay_farm_elementary_school),
        count: count
      )

      get '/gsr/api/schools/?state=ca', format: :json
      expect(status).to eq(200)
      expect(errors).to be_blank
      expect(schools.length).to eq(count)
    end

    it 'does not find inactive school' do
      stub_solr_schools(
        create_school(:alameda_high_school, active: false),
        count: 0
      )
      get '/gsr/api/schools/?state=ca', format: :json
      expect(status).to eq(200)
      expect(errors).to be_blank
      expect(schools).to be_blank
    end

    it 'returns schools matching a district id' do
      stub_solr_schools(
        create_school(:alameda_high_school, district_id: 1),
        create_school(:bay_farm_elementary_school, district_id: 2)
      )
      get '/gsr/api/schools/?state=ca&district_id=2'
      expect(status).to eq(200)
      expect(errors).to be_blank
      expect(schools.size).to eq(1)
      expect(schools.first['districtId']).to eq(2)
    end

    it 'Obeys limit param' do
      count = 1
      stub_solr_schools(
        create_school(:alameda_high_school, name: 'Alameda High School'),
        create_school(:bay_farm_elementary_school),
        count: count
      )

      get "/gsr/api/schools/?state=ca&limit=#{count}", format: :json
      expect(status).to eq(200)
      expect(errors).to be_blank
      expect(schools.length).to eq(count)
      expect(schools.first['name']).to eq('Alameda High School')
    end

    it 'Obeys offset param' do
      count = 1
      stub_solr_schools(
        create_school(:alameda_high_school),
        create_school(:bay_farm_elementary_school, name: 'Cristo Rey New York High School'),
        count: count,
        offset: 1
      )

      get '/gsr/api/schools/?state=ca&offset=1', format: :json
      expect(status).to eq(200)
      expect(errors).to be_blank
      expect(schools.length).to eq(count)
      expect(schools.first['name']).to eq('Cristo Rey New York High School')
    end

    it 'adds "next" when there are more results' do
      count = 1
      stub_solr_schools(
        create_school(:alameda_high_school),
        create_school(:bay_farm_elementary_school),
        count: 1,
        total: 2
      )

      get "/gsr/api/schools/?state=ca&limit=#{count}", format: :json
      expect(status).to eq(200)
      expect(errors).to be_blank
      expect(json['links']).to be_present
      expect(json['links']['next']).to be_present
    end

    it 'adds "prev" when there are prior results' do
      stub_solr_schools(
        create_school(:alameda_high_school),
        create_school(:bay_farm_elementary_school)
      )

      get '/gsr/api/schools/?state=ca&offset=1'
      expect(status).to eq(200)
      expect(errors).to be_blank
      expect(json['links']).to be_present
      expect(json['links']['prev']).to be_present
    end

    it 'adds GS rating when available' do
      rating = 10
      school = create_school(:alameda_high_school)
      stub_solr_schools(school)
      create_school(:cached_ratings, :with_gs_rating,
             state: school.state,
             school_id: school.id,
             gs_rating_value: rating
            )
      get '/gsr/api/schools/?state=ca'
      expect(status).to eq(200)
      expect(errors).to be_blank
      expect(schools.first['rating']).to eq(rating)
    end

    context 'with geometry data available for school' do
      let(:school) { create_school(:alameda_high_school) }
      before do
        str = 'MULTIPOLYGON(((1 1,1 10,10 10,10 1,1 1)))'
        create_geo_data(str)
        stub_solr_schools(school)
      end
      let(:coordinates) do
        [[
          [1, 1],
          [1, 10],
          [10, 10],
          [10, 1],
          [1, 1]
        ]]
      end

      it 'Doesnt include geometry by default' do
        get '/gsr/api/schools/?state=ca'
        expect(status).to eq(200)
        expect(errors).to be_blank
        expect(schools.length).to eq(1)
        expect(schools.first['boundaries']).to_not be_present
      end

      it 'Finds school with boundary containing point' do
        get '/gsr/api/schools/?state=ca&lat=5&lon=5&extras=boundaries'
        expect(status).to eq(200)
        expect(errors).to be_blank
        expect(schools.length).to eq(1)
      end

    end
  end

  def create_school(*args)
    create(*args)
  end

  def stub_solr_schools(*schools, solr_query: nil, count: 1, total: nil, offset: 0)
    total ||= count
    docs = schools.map do |school|
      {
        'state': school.state,
        'school_id': school.id
      }
    end.drop(offset).take(count)

    req = stub_request(:any, /\/solr\/main\/select/)
    req = req.with(body: solr_query) if solr_query
    req.to_return(
      status: 200,
      body: {
        response: {
          docs: docs,
          numFound: total
        }
      }.to_json,
      headers: {}
    )
  end

  def create_geo_data(str)
    SchoolGeometry.connection.execute(
        "insert into school_geometry(state, school_id, ed_level, geom, mx_id)
         values('#{school.state}', #{school.id}, 'O', GeomFromText('#{str}'), '1');"
    )
  end
end
