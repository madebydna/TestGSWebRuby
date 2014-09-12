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

  let(:characteristics_hash) {{
      'Enrollment' => [
          {'year' => 2012,'source' => 'NCES','grade' => '5','school_value' => 10.0},
          {'year' => 2012,'source' => 'NCES','grade' => '4','school_value' => 9.0},
          {'year' => 2012,'source' => 'NCES','grade' => 'KG','school_value' => 8.0},
          {'year' => 2012,'source' => 'NCES','grade' => '1','school_value' => 7.0},
          {'year' => 2012,'source' => 'NCES','grade' => '2','school_value' => 7.0},
          {'year' => 2012,'source' => 'NCES','grade' => '3','school_value' => 6.0},
          {'year' => 2012,'source' => 'NCES','school_value' => 4700.0}
      ]
  }}

  let(:transportation_none_hash) {{
      'transportation' => {'none' => {'member_id' => 5391163,'source' => 'osp','created' => '2013-12-23T12:50:52.000-08:00'}}
  }}

  let(:transportation_some_hash) {{
      'transportation' => {'public_transit' => {'member_id' => 5391163,'source' => 'osp','created' => '2013-12-23T12:50:52.000-08:00'},
                           'none' => {'member_id' => 5391163,'source' => 'osp','created' => '2013-12-23T12:50:52.000-08:00'}}
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

    context 'transportation' do

     it 'should return No for none' do
       allow(school).to receive(:programs).and_return(transportation_none_hash)
       expect(school.transportation).to eq('No')
     end

     it 'should return Yes for some even if none is one of the responses' do
       allow(school).to receive(:programs).and_return(transportation_some_hash)
       expect(school.transportation).to eq('Yes')
     end

      it 'should return NO DATA SYMBOL when no data' do
        allow(school).to receive(:programs).and_return({})
        expect(school.transportation).to eq(SchoolCompareDecorator::NO_DATA_SYMBOL)
      end
    end
  end

  describe 'characteristics' do

    context 'enrollment' do
      it 'should only display enrollment with no grade value' do
        allow(school).to receive(:characteristics).and_return(characteristics_hash)
        expect(school.students_enrolled).to eq('4,700')
      end

      it 'should dispaly NO DATA SYMBOL if there is no enrollment' do
        allow(school).to receive(:characteristics).and_return({})
        expect(school.students_enrolled).to eq(SchoolCompareDecorator::NO_DATA_SYMBOL)
      end
    end
  end
end
