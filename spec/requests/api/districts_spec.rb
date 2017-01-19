require 'spec_helper'

describe "Districts API" do
  after do
    clean_dbs :gs_schooldb, :ca, :us_geo
  end

  let(:json) { JSON.parse(response.body) }
  let(:status) { response.status }
  let(:errors) { json['errors'] }

  describe 'show' do
    it 'Returns district 1 by ID' do
      s1 = create(:alameda_city_unified)
      create(:oakland_unified)

      get "/gsr/api/districts/#{s1.id}?state=ca"
      expect(status).to eq(200)
      expect(errors).to be_blank
      expect(json).to be_present
      expect(json['name']).to eq(s1.name)
    end

    it 'Returns district 2 by ID' do
      create(:alameda_city_unified)
      s2 = create(:oakland_unified)

      get "/gsr/api/districts/#{s2.id}?state=ca"
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

    it 'does not return inactive district' do
      s = create(:alameda_city_unified, active: false)
      get "/gsr/api/districts/#{s.id}?state=#{s.state}", format: :json
      expect(status).to eq(200)
      expect(errors).to be_blank
      expect(json).to be_blank
    end

    it 'Returns a successful (empty) response if ID not found' do
      get "/gsr/api/districts/1?state=ca"
      expect(status).to eq(200)
      expect(errors).to be_blank
      expect(json).to be_blank
    end

    context 'with geometry data available for district' do
      let(:district) { create(:alameda_city_unified) }
      before do
        str = 'MULTIPOLYGON(((1 1,1 10,10 10,10 1,1 1)))'
        DistrictGeometry.connection.execute("insert into school_district_geometry(state, district_id, level_code, geom) values('#{district.state}', #{district.id}, 'e,m,h', GeomFromText('#{str}'));")
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
        get "/gsr/api/districts/#{district.id}?state=ca"
        expect(status).to eq(200)
        expect(errors).to be_blank
        expect(json).to be_present
        expect(json['boundaries']).to_not be_present
      end

      it 'Returns boundary data when asked' do
        get "/gsr/api/districts/#{district.id}?state=ca&boundary_level=e&extras=boundaries"
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
      create(:alameda_city_unified)
      create(:oakland_unified)

      get '/gsr/api/districts/?state=ca', format: :json
      expect(status).to eq(200)
      expect(errors).to be_blank
      expect(districts.length).to eq(2)
    end

    it 'does not find inactive district' do
      create(:alameda_city_unified, active: false)
      get '/gsr/api/districts/?state=ca', format: :json
      expect(status).to eq(200)
      expect(errors).to be_blank
      expect(districts).to be_blank
    end

    it 'Obeys limit param' do
      create(:alameda_city_unified, name: 'Oakland unified')
      create(:oakland_unified)

      get '/gsr/api/districts/?state=ca&limit=1', format: :json
      expect(status).to eq(200)
      expect(errors).to be_blank
      expect(districts.length).to eq(1)
      expect(districts.first['name']).to eq('Oakland unified')
    end

    it 'Obeys offset param' do
      create(:alameda_city_unified)
      create(:oakland_unified, name: 'Oakland unified')

      get '/gsr/api/districts/?state=ca&offset=1', format: :json
      expect(status).to eq(200)
      expect(errors).to be_blank
      expect(districts.length).to eq(1)
      expect(districts.first['name']).to eq('Oakland unified')
    end

    it 'adds "next" when there are more results' do
      create(:alameda_city_unified)
      create(:oakland_unified)

      get '/gsr/api/districts/?state=ca&limit=1', format: :json
      expect(status).to eq(200)
      expect(errors).to be_blank
      expect(json['links']).to be_present
      expect(json['links']['next']).to be_present
    end

    it 'adds "prev" when there are prior results' do
      create(:alameda_city_unified)
      create(:oakland_unified)

      get '/gsr/api/districts/?state=ca&offset=1'
      expect(status).to eq(200)
      expect(errors).to be_blank
      expect(json['links']).to be_present
      expect(json['links']['prev']).to be_present
    end

    it 'adds GS rating when available' do
      rating = 10
      district = create(:alameda_city_unified)
      create(:cached_district_ratings, :with_gs_rating,
             state: district.state,
             district_id: district.id,
             gs_rating_value: rating
            )
      get '/gsr/api/districts/?state=ca'
      expect(status).to eq(200)
      expect(errors).to be_blank
      expect(districts.first['rating']).to eq(rating)
    end

    context 'with geometry data available for district' do
      let(:district) { create(:alameda_city_unified) }
      before do
        str = 'MULTIPOLYGON(((1 1,1 10,10 10,10 1,1 1)))'
        DistrictGeometry.connection.execute("insert into school_district_geometry(state, district_id, level_code, geom) values('#{district.state}', #{district.id}, 'e,m,h', GeomFromText('#{str}'));")
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

end
