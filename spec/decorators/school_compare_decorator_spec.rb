require 'spec_helper'
require 'decorators/concerns/grade_level_concerns_shared'

describe SchoolCompareDecorator do
  let(:school) { SchoolCompareDecorator.decorate(FactoryGirl.build(:school_search_result)) }
  let(:programs_counts_hash) {{
      'academic_focus' => { 'none' => {member_id: 5652558, source: 'osp', created: '2014-08-15T10:35:23.000-07:00'}},
      'boys_sports' => {
          'baseball' => {member_id: 5652558, source: 'osp', created: '2014-08-15T10:37:11.000-07:00'},
          'basketball' => {member_id: 5652558, source: 'osp', created: '2014-08-15T10:37:11.000-07:00'},
          'none' => {member_id: 5652558, source: 'osp', created: '2014-08-15T10:35:23.000-07:00'}
      },
  }}
  let(:only_after_hash) {{
      'before_after_care' => {'after' => {member_id: 5059707, source: 'osp', created: '2013-07-22T11:18:32.000-07:00'}}
  }}
  let(:only_before_hash) {{
      'before_after_care' => {'before' => {member_id: 5059707, source: 'osp', created: '2013-07-22T11:18:32.000-07:00'}}
  }}
  let(:before_after_both_hash) {{
      'before_after_care' => {'after' => {member_id: 5059707, source: 'osp', created: '2013-07-22T11:18:32.000-07:00'},
                              'before' => {member_id: 5059707, source: 'osp', created: '2013-07-22T11:18:32.000-07:00'}}
  }}
  let(:before_after_neither_hash) {{
      'before_after_care' => {'neither' => {member_id: 5059707, source: 'osp', created: '2013-07-22T11:18:32.000-07:00'}}
  }}



  describe 'programs' do

    context 'counting programs' do
      it 'should correctly count programs by excluding none from the counts' do
        allow(school).to receive(:programs).and_return(programs_counts_hash)
        expect(school.num_programs('academic_focus')).to eq(0)
        expect(school.num_programs('boys_sports')).to eq(2)
      end
    end

    context 'before care and after school' do

      it 'should handle only after school correctly' do
        allow(school).to receive(:programs).and_return(only_after_hash)
        expect(school.before_care).to eq(SchoolCompareDecorator::NO_DATA_SYMBOL)
        expect(school.after_school).to eq('Yes')
      end
      it 'should handle only before care correctly' do
        allow(school).to receive(:programs).and_return(only_before_hash)
        expect(school.after_school).to eq(SchoolCompareDecorator::NO_DATA_SYMBOL)
        expect(school.before_care).to eq('Yes')
      end
      it 'should handle both correctly' do
        allow(school).to receive(:programs).and_return(before_after_both_hash)
        expect(school.before_care).to eq('Yes')
        expect(school.after_school).to eq('Yes')
      end
      it 'should handle neither correctly' do
        allow(school).to receive(:programs).and_return(before_after_neither_hash)
        expect(school.before_care).to eq('No')
        expect(school.after_school).to eq('No')
      end
      it 'should handle missing data correctly' do
        allow(school).to receive(:programs).and_return({})
        expect(school.before_care).to eq(SchoolCompareDecorator::NO_DATA_SYMBOL)
        expect(school.after_school).to eq(SchoolCompareDecorator::NO_DATA_SYMBOL)
      end
    end
  end
end
