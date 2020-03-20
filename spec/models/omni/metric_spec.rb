require 'spec_helper'

describe Omni::Metric do
  after { clean_dbs :omni, :ca }

  describe 'scopes' do
    it '.state_entity filters by entity_type state' do
      state_metric = create(:metric, entity_type: Omni::Metric::STATE_ENTITY)
      school_metric = create(:metric, entity_type: Omni::Metric::SCHOOL_ENTITY)
      expect(Omni::Metric.state_entity).to include(state_metric)
      expect(Omni::Metric.state_entity).not_to include(school_metric)
    end

    it '.district_entity filters by entity_type district' do
      state_metric = create(:metric, entity_type: Omni::Metric::STATE_ENTITY)
      district_metric = create(:metric, entity_type: Omni::Metric::DISTRICT_ENTITY)
      expect(Omni::Metric.district_entity).to include(district_metric)
      expect(Omni::Metric.district_entity).not_to include(state_metric)
    end

    it '.school_entity filters by entity_type school' do
      district_metric = create(:metric, entity_type: Omni::Metric::DISTRICT_ENTITY)
      school_metric = create(:metric, entity_type: Omni::Metric::SCHOOL_ENTITY)
      expect(Omni::Metric.school_entity).to include(school_metric)
      expect(Omni::Metric.school_entity).not_to include(district_metric)
    end

    it '.for_school filters by provided school' do
      school1 = create(:school, state: 'CA')
      school2 = create(:school, state: 'CA')
      school1_metric1 = create(:metric, entity_type: Omni::Metric::SCHOOL_ENTITY, gs_id: school1.id)
      school1_metric2 = create(:metric, entity_type: Omni::Metric::SCHOOL_ENTITY, gs_id: school1.id)
      school2_metric1 = create(:metric, entity_type: Omni::Metric::SCHOOL_ENTITY, gs_id: school2.id)

      scope = Omni::Metric.for_school(school1)
      expect(scope).to include(school1_metric1)
      expect(scope).to include(school1_metric2)
      expect(scope).not_to include(school2_metric1)
    end

    it '.for_district filters by provided district' do
      district1 = create(:district, state: 'CA')
      district2 = create(:district, state: 'CA')
      district1_metric1 = create(:metric, entity_type: Omni::Metric::DISTRICT_ENTITY, gs_id: district1.id)
      district1_metric2 = create(:metric, entity_type: Omni::Metric::DISTRICT_ENTITY, gs_id: district1.id)
      district2_metric1 = create(:metric, entity_type: Omni::Metric::DISTRICT_ENTITY, gs_id: district2.id)

      scope = Omni::Metric.for_district(district1)
      expect(scope).to include(district1_metric1)
      expect(scope).to include(district1_metric2)
      expect(scope).not_to include(district2_metric1)
    end

    it '.for_state filters by provided state' do
      state1 = create(:state, state: 'Califronia', abbreviation: 'CA')
      state2 = create(:state, state: 'Texas', abbreviation: 'TX')
      state1_metric1 = create(:metric, entity_type: Omni::Metric::STATE_ENTITY, gs_id: state1.id)
      state1_metric2 = create(:metric, entity_type: Omni::Metric::STATE_ENTITY, gs_id: state1.id)
      state2_metric1 = create(:metric, entity_type: Omni::Metric::STATE_ENTITY, gs_id: state2.id)

      scope = Omni::Metric.for_state(state1)
      expect(scope).to include(state1_metric1)
      expect(scope).to include(state1_metric2)
      expect(scope).not_to include(state2_metric1)
    end
  end
end