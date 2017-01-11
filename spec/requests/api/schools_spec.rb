require 'spec_helper'

describe "Schools API" do
  let(:json) { JSON.parse(response.body) }
  let(:errors) { json['errors'] }
  let(:status) { response.status }
  let(:schools) { json['items'] }

  after do
    clean_dbs :gs_schooldb, :ca, :us_geo
  end

  it 'Requires a state' do
    get '/gsr/api/schools/', format: :json
    expect(status).to be(404)
    expect(errors).to be_present
  end

  it 'Returns some schools' do
    create(:alameda_high_school)
    create(:cristo_rey_new_york_high_school)

    get '/gsr/api/schools/?state=ca', format: :json
    expect(status).to eq(200)
    expect(errors).to be_blank
    expect(schools.length).to eq(2)
  end

  it 'returns schools matching a district id' do
    create(:alameda_high_school, district_id: 1)
    create(:cristo_rey_new_york_high_school, district_id: 2)
    get '/gsr/api/schools/?state=ca&offset=1'
    expect(status).to eq(200)
    expect(errors).to be_blank
    expect(schools.size).to eq(1)
    expect(schools.first['districtId']).to eq(2)
  end

  it 'Obeys limit param' do
    create(:alameda_high_school)
    create(:cristo_rey_new_york_high_school)

    get '/gsr/api/schools/?state=ca&limit=1', format: :json
    expect(status).to eq(200)
    expect(errors).to be_blank
    expect(schools.length).to eq(1)
  end

  it 'Obeys limit param' do
    create(:alameda_high_school, name: 'Alameda High School')
    create(:cristo_rey_new_york_high_school)

    get '/gsr/api/schools/?state=ca&limit=1', format: :json
    expect(status).to eq(200)
    expect(errors).to be_blank
    expect(schools.length).to eq(1)
    expect(schools.first['name']).to eq('Alameda High School')
  end

  it 'Obeys offset param' do
    create(:alameda_high_school)
    create(:cristo_rey_new_york_high_school, name: 'Cristo Rey New York High School')

    get '/gsr/api/schools/?state=ca&offset=1', format: :json
    expect(status).to eq(200)
    expect(errors).to be_blank
    expect(schools.length).to eq(1)
    expect(schools.first['name']).to eq('Cristo Rey New York High School')
  end

  it 'adds "next" when there are more results' do
    create(:alameda_high_school)
    create(:cristo_rey_new_york_high_school)

    get '/gsr/api/schools/?state=ca&limit=1', format: :json
    expect(status).to eq(200)
    expect(errors).to be_blank
    expect(json['links']).to be_present
    expect(json['links']['next']).to be_present
  end

  it 'adds "prev" when there are prior results' do
    create(:alameda_high_school)
    create(:cristo_rey_new_york_high_school)

    get '/gsr/api/schools/?state=ca&offset=1'
    expect(status).to eq(200)
    expect(errors).to be_blank
    expect(json['links']).to be_present
    expect(json['links']['prev']).to be_present
  end

  context 'with geometry data available for school' do
    before do
      str = 'MULTIPOLYGON(((-75.4785828 40.6019644,-75.47811 40.6009279,-75.4779185 40.6005256,-75.4785828 40.6019644)))'
      school = create(:alameda_high_school)
      SchoolGeometry.connection.execute("insert into school_geometry(school_id, geom) values(#{school.id}, GeomFromText('#{str}'));")
    end
    let(:boundary) do
      [[
        [-75.4785828, 40.6019644],
        [-75.47811, 40.6009279],
        [-75.4779185, 40.6005256],
        [-75.4785828, 40.6019644]
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
  end

end
