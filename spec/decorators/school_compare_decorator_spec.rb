require 'spec_helper'
require 'decorators/concerns/grade_level_concerns_shared'

RSpec.configure do |c|
  c.include CompareSchoolsConcerns
end

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

  let(:ethnicity_data_hash) {[
      {'year'=>2012,
       'source'=>'Source',
       'breakdown'=>'Schoolstate val brkdwn',
       'school_value'=>40.63,
       'state_average'=>1.15},
      {'year'=>2012,
       'source'=>'Source',
       'breakdown'=>'Another valid breakdown',
       'school_value'=>46.09,
       'state_average'=>13.0},
      {'year'=>2012,
       'source'=>'Source',
       'breakdown'=>'No state value breakdown',
       'school_value'=>11.33},
      {'year'=>2012,
       'source'=>'Source',
       'breakdown'=>'No school value breakdown',
       'state_average'=>1.0},
      {'year'=>2012,
       'source'=>'Source',
       'breakdown'=>'Zero valued breakdown',
       'school_value'=>0.0,
       'state_average'=>0.0}
  ]}

  let(:ratings_hash) {[
      {'data_type_id'=>164,
       'year'=>2014,
       'school_value_text'=>nil,
       'school_value_float'=>10.0,
       'name'=>'Test score rating'},
      {'data_type_id'=>165,
       'year'=>2014,
       'school_value_text'=>nil,
       'school_value_float'=>8.0,
      },
      {'data_type_id'=>174,
       'year'=>2014,
       'school_value_text'=>nil,
       'school_value_float'=>10.0,
       'name'=>'GreatSchools rating'}
  ]}

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

    context 'ethnicity' do

      context 'icon' do
        it 'should have the icon method' do
          expect(school).to respond_to(:ethnicity_label_icon)
        end

        it 'should have the square and js classes' do
          expect(school.ethnicity_label_icon).to match('square')
          expect(school.ethnicity_label_icon).to match('js-comparePieChartSquare')
        end
      end

      context '#school_ethnicity' do
        before do
          allow(school).to receive(:ethnicity_data).and_return(ethnicity_data_hash)
          instance_variable_set('@schools', [school])
          prep_school_ethnicity_data!
        end

        it 'should display NO_ETHNICITY_SYMBOL where the school has no school_value' do
          expect(school.school_ethnicity('No school value breakdown')).to eq(SchoolCompareDecorator::NO_ETHNICITY_SYMBOL)
        end

        it 'should display NO_ETHNICITY_SYMBOL where the school does not have that breakdown' do
          expect(school.school_ethnicity('Random breakdown')).to eq(SchoolCompareDecorator::NO_ETHNICITY_SYMBOL)
        end

        it 'should display the school\' value, rounded with a percent' do
          expect(school.school_ethnicity('Schoolstate val brkdwn')).to eq('41%')
        end
      end

    end

    context 'ratings' do
      before do
        allow(school).to receive(:ratings).and_return(ratings_hash)
        instance_variable_set('@schools', [school])
        prep_school_ratings!
      end

      context '#school_rating_by_name' do

        it 'should return NO_RATING_TEXT with no argument' do
          expect(school.school_rating_by_name).to eq(SchoolCompareDecorator::NO_RATING_TEXT)
        end

        it 'should return NO_RATING_TEXT with nil' do
          expect(school.school_rating_by_name(nil)).to eq(SchoolCompareDecorator::NO_RATING_TEXT)
        end

        it 'should return the rating as an integer if there is one' do
          expect(school.school_rating_by_name('GreatSchools rating')).to eq(10)
          expect(school.school_rating_by_name('GreatSchools rating').class).to eq(Fixnum)
        end
      end

      context '#great_schools_rating_icon' do

        it 'should default to the NR symbol' do
          expect(school.great_schools_rating_icon).to eq("<i class='iconx24-icons i-24-new-ratings-nr'></i>")
        end

        it 'should return the NR symbol when there is no school value' do
          expect(school.great_schools_rating_icon('Random rating')).to eq("<i class='iconx24-icons i-24-new-ratings-nr'></i>")
        end

        it 'should return the correct symbol when there is a rating' do
          expect(school.great_schools_rating_icon('GreatSchools rating')).to eq("<i class='iconx24-icons i-24-new-ratings-10'></i>")
        end
      end

    end
  end
end
