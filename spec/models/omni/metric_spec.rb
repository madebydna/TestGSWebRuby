require 'spec_helper'

describe Omni::Metric do
  after { clean_dbs :omni, :ca }

  describe 'scopes' do
    let(:data_set) {create(:data_set, state: 'CA') }
    it '.state_entity filters by entity_type state' do
      state_metric = create(:metric, entity_type: Omni::Metric::STATE_ENTITY)
      school_metric = create(:metric, entity_type: Omni::Metric::SCHOOL_ENTITY)
      expect(Omni::Metric.state_entity).to contain_exactly(state_metric)
    end

    it '.district_entity filters by entity_type district' do
      state_metric = create(:metric, entity_type: Omni::Metric::STATE_ENTITY)
      district_metric = create(:metric, entity_type: Omni::Metric::DISTRICT_ENTITY)
      expect(Omni::Metric.district_entity).to contain_exactly(district_metric)
    end

    it '.school_entity filters by entity_type school' do
      district_metric = create(:metric, entity_type: Omni::Metric::DISTRICT_ENTITY)
      school_metric = create(:metric, entity_type: Omni::Metric::SCHOOL_ENTITY)
      expect(Omni::Metric.school_entity).to contain_exactly(school_metric)
    end

    it '.for_school filters by provided school' do
      school1 = create(:school, state: 'CA')
      school2 = create(:school, state: 'CA')
      school1_metric1 = create(:metric, entity_type: Omni::Metric::SCHOOL_ENTITY, gs_id: school1.id)
      school1_metric2 = create(:metric, entity_type: Omni::Metric::SCHOOL_ENTITY, gs_id: school1.id)
      school2_metric1 = create(:metric, entity_type: Omni::Metric::SCHOOL_ENTITY, gs_id: school2.id)

      scope = Omni::Metric.for_school(school1)
      expect(scope).to contain_exactly(school1_metric1, school1_metric2)
    end

    it '.for_district filters by provided district' do
      district1 = create(:district, state: 'CA')
      district2 = create(:district, state: 'CA')
      district1_metric1 = create(:metric, data_set: data_set, entity_type: Omni::Metric::DISTRICT_ENTITY, gs_id: district1.id)
      district1_metric2 = create(:metric, data_set: data_set, entity_type: Omni::Metric::DISTRICT_ENTITY, gs_id: district1.id)
      district2_metric1 = create(:metric, data_set: data_set, entity_type: Omni::Metric::DISTRICT_ENTITY, gs_id: district2.id)

      scope = Omni::Metric.for_district(district1)
      expect(scope).to contain_exactly(district1_metric1, district1_metric2)
    end

    it '.for_state filters by provided state' do
      state1 = create(:state, state: 'Califronia', abbreviation: 'CA')
      state2 = create(:state, state: 'Texas', abbreviation: 'TX')
      state1_metric1 = create(:metric, data_set: data_set, entity_type: Omni::Metric::STATE_ENTITY, gs_id: state1.id)
      state1_metric2 = create(:metric, data_set: data_set, entity_type: Omni::Metric::STATE_ENTITY, gs_id: state1.id)
      state2_metric1 = create(:metric, entity_type: Omni::Metric::STATE_ENTITY, gs_id: state2.id)

      scope = Omni::Metric.for_state(state1)
      expect(scope).to contain_exactly(state1_metric1, state1_metric2)
    end

    it '.filter_by_data_types filters by supplied list of data_type ids' do
      data_type1 = create(:data_type, :with_data_set, state: 'CA')
      data_type2 = create(:data_type, :with_data_set, state: 'CA')
      data_type3 = create(:data_type, :with_data_set, state: 'CA')

      metric1 = create(:metric, data_set: data_type1.data_sets.first)
      metric2 = create(:metric, data_set: data_type2.data_sets.first)
      metric3 = create(:metric, data_set: data_type3.data_sets.first)

      scope = Omni::Metric.filter_by_data_types([data_type1.id, data_type3.id])
      expect(scope).to contain_exactly(metric1, metric3)
    end

    describe '.include_entity_average' do
      context 'with a district' do
        it 'should add a district_value field to results' do
          district = create(:district, state: 'CA')
          school = create(:school, state: 'CA', district_id: district.id)
          school_metric = create(:metric, data_set: data_set, entity_type: Omni::Metric::SCHOOL_ENTITY, gs_id: school.id)
          district_metric = create(:metric,
            value: 123,
            data_set: data_set,
            entity_type: Omni::Metric::DISTRICT_ENTITY,
            gs_id: district.id,
            breakdown_id: school_metric.breakdown_id,
            subject_id: school_metric.subject_id,
            grade: school_metric.grade
          )

          scope = Omni::Metric.for_school(school).include_entity_average(type: 'district', id: district.id)
          expect(scope.first).to respond_to(:district_value)
          expect(scope.first.district_value).to eq('123')
        end
      end

      context 'with a state' do
        it 'should add a state_value field to results' do
          state = create(:state, state: 'Califronia', abbreviation: 'CA')
          school = create(:school, state: 'CA')
          school_metric = create(:metric, data_set: data_set, entity_type: Omni::Metric::SCHOOL_ENTITY, gs_id: school.id)
          state_metric = create(:metric,
            value: 123,
            data_set: data_set,
            entity_type: Omni::Metric::STATE_ENTITY,
            gs_id: state.id,
            breakdown_id: school_metric.breakdown_id,
            subject_id: school_metric.subject_id,
            grade: school_metric.grade
          )

          scope = Omni::Metric.for_school(school).include_entity_average(type: 'state', id: state.id)
          expect(scope.first).to respond_to(:state_value)
          expect(scope.first.state_value).to eq('123')
        end
      end
    end
  end
end