require 'spec_helper'

shared_context 'when there is a deactivated test_data_set' do
  let(:test_data_set_attrs) do
    {
      id: 1,
      data_type_id: 1,
      breakdown_id: 1,
      subject_id: 1,
      display_target: 'ratings',
      school_id: 1,
      value_float: 2,
      value_text: '3',
      number_tested: 300,
      active: 1
    }
  end
  let(:school) { FactoryGirl.build(:school, id: 1) }
  before do
    FactoryGirl.create(:test_data_set, :with_school_values, test_data_set_attrs.merge(active: 0))
  end
  after do
    clean_dbs :ca
  end
end

shared_context 'when there is an active test_data_set with a deactivated test_data_school_value' do
  let(:test_data_set_attrs) do
    {
      id: 1,
      data_type_id: 1,
      breakdown_id: 1,
      subject_id: 1,
      display_target: 'ratings',
      school_id: 1,
      value_float: 2,
      value_text: '3',
      number_tested: 300,
      active: 1
    }
  end
  let(:school) { FactoryGirl.build(:school, id: 1) }
  before do
    FactoryGirl.create(:test_data_set, :with_school_values, test_data_set_attrs.merge(school_value_active: 0))
  end
  after do
    clean_dbs :ca
  end
end
