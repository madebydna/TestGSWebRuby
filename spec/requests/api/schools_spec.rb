require 'spec_helper'

describe "Schools API" do
  after do
    clean_dbs :gs_schooldb, :ca, :us_geo
  end

  let(:json) { JSON.parse(response.body) }
  let(:status) { response.status }
  let(:errors) { json['errors'] }

  describe 'show' do
    let(:school) { json }

    it 'Returns school 1 by ID' do
      s1 = create(:alameda_high_school)
      create(:bay_farm_elementary_school)

      get "/gsr/api/schools/#{s1.id}?state=ca"
      expect(status).to eq(200)
      expect(errors).to be_blank
      expect(school).to be_present
      expect(school['name']).to eq(s1.name)
    end

    it 'Returns school 2 by ID' do
      create(:alameda_high_school)
      s2 = create(:bay_farm_elementary_school)

      get "/gsr/api/schools/#{s2.id}?state=ca"
      expect(status).to eq(200)
      expect(errors).to be_blank
      expect(school).to be_present
      expect(school['name']).to eq(s2.name)
    end

    it 'Returns a successful (empty) response if ID not found' do
      get "/gsr/api/schools/1?state=ca"
      expect(status).to eq(200)
      expect(errors).to be_blank
      expect(school).to be_blank
    end
  end

  describe 'index' do
    let(:schools) { json['items'] }

    it 'Requires a state' do
      get '/gsr/api/schools/', format: :json
      expect(status).to be(404)
      expect(errors).to be_present
    end

    it 'Returns some schools' do
      create(:alameda_high_school)
      create(:bay_farm_elementary_school)

      get '/gsr/api/schools/?state=ca', format: :json
      expect(status).to eq(200)
      expect(errors).to be_blank
      expect(schools.length).to eq(2)
    end

    it 'returns schools matching a district id' do
      create(:alameda_high_school, district_id: 1)
      create(:bay_farm_elementary_school, district_id: 2)
      get '/gsr/api/schools/?state=ca&offset=1'
      expect(status).to eq(200)
      expect(errors).to be_blank
      expect(schools.size).to eq(1)
      expect(schools.first['districtId']).to eq(2)
    end

    it 'Obeys limit param' do
      create(:alameda_high_school, name: 'Alameda High School')
      create(:bay_farm_elementary_school)

      get '/gsr/api/schools/?state=ca&limit=1', format: :json
      expect(status).to eq(200)
      expect(errors).to be_blank
      expect(schools.length).to eq(1)
      expect(schools.first['name']).to eq('Alameda High School')
    end

    it 'Obeys offset param' do
      create(:alameda_high_school)
      create(:bay_farm_elementary_school, name: 'Cristo Rey New York High School')

      get '/gsr/api/schools/?state=ca&offset=1', format: :json
      expect(status).to eq(200)
      expect(errors).to be_blank
      expect(schools.length).to eq(1)
      expect(schools.first['name']).to eq('Cristo Rey New York High School')
    end

    it 'adds "next" when there are more results' do
      create(:alameda_high_school)
      create(:bay_farm_elementary_school)

      get '/gsr/api/schools/?state=ca&limit=1', format: :json
      expect(status).to eq(200)
      expect(errors).to be_blank
      expect(json['links']).to be_present
      expect(json['links']['next']).to be_present
    end

    it 'adds "prev" when there are prior results' do
      create(:alameda_high_school)
      create(:bay_farm_elementary_school)

      get '/gsr/api/schools/?state=ca&offset=1'
      expect(status).to eq(200)
      expect(errors).to be_blank
      expect(json['links']).to be_present
      expect(json['links']['prev']).to be_present
    end

    context 'with geometry data available for school' do
      before do
        str = 'MULTIPOLYGON(((1 1,1 10,10 10,10 1,1 1)))'
        school = create(:alameda_high_school)
        SchoolGeometry.connection.execute("insert into school_geometry(school_id, geom) values(#{school.id}, GeomFromText('#{str}'));")
      end
      let(:boundary) do
        [[
          [1, 1],
          [1, 10],
          [10, 10],
          [10, 1],
          [1, 1]
        ]]
      end

      it 'Returns geometry data when asked' do
        get '/gsr/api/schools/?state=ca&extras=geometry'
        expect(status).to eq(200)
        expect(errors).to be_blank
        expect(schools.length).to eq(1)
        expect(schools.first['geometry']).to be_present
        expect(schools.first['geometry']['boundary']).to eq(boundary)
      end

      it 'Doesnt include geometry by default' do
        get '/gsr/api/schools/?state=ca'
        expect(status).to eq(200)
        expect(errors).to be_blank
        expect(schools.length).to eq(1)
        expect(schools.first['geometry']).to_not be_present
      end

      it 'Finds school with boundary containing point' do
        get '/gsr/api/schools/?state=ca&lat=5&lon=5'
        expect(status).to eq(200)
        expect(errors).to be_blank
        expect(schools.length).to eq(1)
      end
    end
  end

end
