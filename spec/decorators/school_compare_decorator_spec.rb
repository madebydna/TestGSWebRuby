require 'spec_helper'
require 'decorators/concerns/grade_level_concerns_shared'

describe SchoolCompareDecorator do
  let(:school) { SchoolCompareDecorator.decorate(FactoryGirl.build(:school_search_result)) }
  let(:programs_hash) {{
        'academic_focus' => { 'none' => {member_id: 5652558, source: 'osp', created: '2014-08-15T10:35:23.000-07:00'}},
        'boys_sports' => {
            'baseball' => {member_id: 5652558, source: 'osp', created: '2014-08-15T10:37:11.000-07:00'},
            'basketball' => {member_id: 5652558, source: 'osp', created: '2014-08-15T10:37:11.000-07:00'},
            'none' => {member_id: 5652558, source: 'osp', created: '2014-08-15T10:35:23.000-07:00'}
        }
  }}

  context 'programs' do

    it 'should correctly count programs by excluding none from the counts' do
      allow(school).to receive(:programs).and_return(programs_hash)
      expect(school.num_programs('academic_focus')).to eq(0)
      expect(school.num_programs('boys_sports')).to eq(2)
    end
  end
end
