require 'spec_helper'

describe "Districts API" do
  before(:all) do
    head '/'
    @csrf_token = request.cookie_jar.fetch(:csrf_token)
  end

  def get(path, hash={})
    super(path, hash, { 'X-CSRF-Token' => @csrf_token })
  end

  after do
    clean_dbs :gs_schooldb, :ca, :us_geo
  end

  let(:json) { JSON.parse(response.body) }
  let(:status) { response.status }
  let(:errors) { json['errors'] }

  describe 'show' do
    it 'Returns district 1 by ID' do
      s1 = create(:alameda_city_unified_district_record)
      create(:oakland_unified_district_record)

      get "/gsr/api/districts/#{s1.district_id}?state=ca"
      expect(status).to eq(200)
      expect(errors).to be_blank
      expect(json).to be_present
      expect(json['name']).to eq(s1.name)
    end

    it 'Returns district 2 by ID' do
      create(:alameda_city_unified_district_record)
      s2 = create(:oakland_unified_district_record)

      get "/gsr/api/districts/#{s2.district_id}?state=ca"
      expect(status).to eq(200)
      expect(errors).to be_blank
      expect(json).to be_present
      expect(json['name']).to eq(s2.name)
    end

    it 'Requires a state' do
      get '/gsr/api/districts/', format: :json
      expect(status).to be(404)
      expect(errors).to be_present
    end

    it 'Returns a successful (empty) response if ID not found' do
      get "/gsr/api/districts/1?state=ca"
      expect(status).to eq(200)
      expect(errors).to be_blank
      expect(json).to be_blank
    end

    context 'with geometry data available for district' do
      let(:district) { create(:alameda_city_unified_district_record) }
      before do
        str = 'MULTIPOLYGON(((1 1,1 10,10 10,10 1,1 1)))'
        create_geo_data(str)
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
        get "/gsr/api/districts/#{district.district_id}?state=ca"
        expect(status).to eq(200)
        expect(errors).to be_blank
        expect(json).to be_present
        expect(json['boundaries']).to_not be_present
      end

      it 'Returns boundary data when asked' do
        get "/gsr/api/districts/#{district.district_id}?state=ca&boundary_level=e&extras=boundaries"
        expect(status).to eq(200)
        expect(errors).to be_blank
        expect(json).to be_present
        expect(json['boundaries']).to be_present
        expect(json['boundaries']['e,m,h']['coordinates']).to eq(coordinates)
      end
    end
  end

  describe 'index' do
    let(:districts) { json['items'] }

    it 'Requires a state when location unknown' do
      get '/gsr/api/districts/', format: :json
      expect(status).to be(404)
      expect(errors).to be_present
    end

    it "Doesn't require a state when lat/lon provided" do
      get '/gsr/api/districts/?lat=1&lon=1', format: :json
      expect(status).to be(200)
      expect(errors).to be_blank
    end

    it 'Returns some districts' do
      create(:alameda_city_unified_district_record)
      create(:oakland_unified_district_record)

      get '/gsr/api/districts/?state=ca', format: :json
      expect(status).to eq(200)
      expect(errors).to be_blank
      expect(districts.length).to eq(2)
    end

    it 'Obeys limit param' do
      create(:alameda_city_unified_district_record, name: 'Oakland unified')
      create(:oakland_unified_district_record)

      get '/gsr/api/districts/?state=ca&limit=1', format: :json
      expect(status).to eq(200)
      expect(errors).to be_blank
      expect(districts.length).to eq(1)
      expect(districts.first['name']).to eq('Oakland unified')
    end

    it 'Obeys offset param' do
      create(:alameda_city_unified_district_record)
      create(:oakland_unified_district_record, name: 'Oakland unified')

      get '/gsr/api/districts/?state=ca&offset=1', format: :json
      expect(status).to eq(200)
      expect(errors).to be_blank
      expect(districts.length).to eq(1)
      expect(districts.first['name']).to eq('Oakland unified')
    end

    it 'adds "next" when there are more results' do
      create(:alameda_city_unified_district_record)
      create(:oakland_unified_district_record)

      get '/gsr/api/districts/?state=ca&limit=1', format: :json
      expect(status).to eq(200)
      expect(errors).to be_blank
      expect(json['links']).to be_present
      expect(json['links']['next']).to be_present
    end

    it 'adds "prev" when there are prior results' do
      create(:alameda_city_unified_district_record)
      create(:oakland_unified_district_record)

      get '/gsr/api/districts/?state=ca&offset=1'
      expect(status).to eq(200)
      expect(errors).to be_blank
      expect(json['links']).to be_present
      expect(json['links']['prev']).to be_present
    end

    it 'adds district schools summary when available' do
      district = create(:alameda_city_unified_district_record)
      create(:cached_district_schools_summary,
             state: district.state.upcase,
             district_id: district.district_id)
      get '/gsr/api/districts/?state=ca'
      expect(status).to eq(200)
      expect(errors).to be_blank
      expect(districts.first['schoolCountsByLevelCode']).to be_present
    end

    context 'with geometry data available for district' do
      let(:district) { create(:alameda_city_unified_district_record) }
      before do
        str = 'MULTIPOLYGON(((1 1,1 10,10 10,10 1,1 1)))'
        create_geo_data(str)
      end

      it 'Doesnt include geometry by default' do
        get '/gsr/api/districts/?state=ca'
        expect(status).to eq(200)
        expect(errors).to be_blank
        expect(districts.length).to eq(1)
        expect(districts.first['boundaries']).to_not be_present
      end

      it 'Finds district with boundary containing point' do
        get '/gsr/api/districts/?state=ca&lat=5&lon=5'
        expect(status).to eq(200)
        expect(errors).to be_blank
        expect(districts.length).to eq(1)
      end

    end
  end

  def create_geo_data(str)
    DistrictGeometry.connection.execute(
        "insert into school_district_geometry(state, district_id, level_code, geom, nces_disid)
         values('#{district.state}', #{district.district_id}, 'e,m,h', GeomFromText('#{str}'), '1');")
  end

end

