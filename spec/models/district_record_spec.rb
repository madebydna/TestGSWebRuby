require 'spec_helper'

describe DistrictRecord do
  after do
    do_clean_dbs :gs_schooldb, :ca
  end

  it 'infers unique_id based on state and district_id' do
    dr = FactoryBot.build(:district_record, state: "ca", district_id: 2000)
    expect(dr.unique_id).to eq("ca-2000")
  end

  it 'saves record without unique_id explicitly set' do
    dr = FactoryBot.build(:district_record, state: "ca", district_id: 2000)
    expect(dr.save).to be true
  end

  it 'validates that district_ids are unique within a state' do
    dr = FactoryBot.create(:district_record, state: "ca", district_id: 1)
    dr2 = FactoryBot.build(:district_record, state: "ca", district_id: 2)
    dr3 = FactoryBot.build(:district_record, state: "ca", district_id: 1)
    dr4 = FactoryBot.build(:district_record, state: "tx", district_id: 1)
    expect(dr2).to be_valid
    expect(dr3).not_to be_valid
    expect(dr4).to be_valid
  end

  describe 'class methods' do
    before do
      @ca_1 = FactoryBot.create(:alameda_city_unified_district_record)
      @ca_2 = FactoryBot.create(:oakland_unified_district_record, active: false)
      @al_1 = FactoryBot.create(:shelby_school_district_record, state: "al")
    end


    describe '.by_state' do
      it 'filters by given state' do
        ca_districts = DistrictRecord.by_state('ca').map(&:name)
        expect(ca_districts).to include(@ca_1.name)
        expect(ca_districts).to include(@ca_2.name)
        expect(ca_districts).not_to include(@al_1.name)
      end
    end

    describe '.active' do
      it 'filters for active districts' do
        active_districts = DistrictRecord.active.map(&:name)
        expect(active_districts).to include(@ca_1.name)
        expect(active_districts).to include(@al_1.name)
        expect(active_districts).not_to include(@ca_2.name)
      end
    end

    describe '.ids_by_state' do
      it 'returns array of ids by state' do
        ca_district_ids = DistrictRecord.ids_by_state("ca")
        expect(ca_district_ids).to include(@ca_1.district_id)
        expect(ca_district_ids).to include(@ca_2.district_id)
      end
    end

    describe '.update_from_district' do
      it 'updates record according to attributes of district' do
        district = FactoryBot.create_on_shard(:ca, :district, id: @ca_1.district_id, name: @ca_1.name)
        district.name = "Awesome Schools of Alameda"
        DistrictRecord.update_from_district(district, "ca")
        expect(@ca_1.reload.name).to eq("Awesome Schools of Alameda")
      end
    end
  end


end