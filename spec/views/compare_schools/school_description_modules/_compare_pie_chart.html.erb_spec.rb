require 'spec_helper'

describe 'compare_schools/school_description_modules/details/_compare_pie_chart.html.erb' do
  let(:ethnicity_data) {[
      {'year'=>2012,
       'source'=>'NCES',
       'breakdown'=>'Schoolstate val brkdwn',
       'school_value'=>40.63,
       'state_average'=>1.15},
      {'year'=>2012,
       'source'=>'NCES',
       'breakdown'=>'Another valid breakdown',
       'school_value'=>46.09,
       'state_average'=>13.0},
      {'year'=>2012,
       'source'=>'Source',
       'breakdown'=>'No state value breakdown',
       'school_value'=>11.33},
      {'year'=>2012,
       'source'=>'NCES',
       'breakdown'=>'No school value breakdown',
       'state_average'=>1.0},
      {'year'=>2012,
       'source'=>'NCES',
       'breakdown'=>'Zero valued breakdown',
       'school_value'=>0.0,
       'state_average'=>0.0},
      {'year'=>2012,
       'source'=>'NCES',
       'breakdown'=>'Hawaiian Native/Pacific Islander',
       'school_value'=>0.0,
       'state_average'=>0.0}
  ]}

  let(:school) { FactoryGirl.build(:an_elementary_school) }
  let(:decorated_school) { SchoolCompareDecorator.new(school) }
  let(:school_path) { 'www.greatschools.org/state/city/55-school/' }

  before do
    assign(:school, decorated_school)
  end

  context 'when no ethnicity data are present' do
    before do
      allow_any_instance_of(SchoolCompareDecorator).to receive(:ethnicity_data).and_return([])
      render
    end

    it 'does not display any breakdowns' do
      ethnicity_data.each do |ethnicity|
        breakdown = ethnicity['breakdown']
        expect(rendered).to_not have_content truncate(breakdown, length: 28)
      end
    end
  end

  context 'when ethnicity data is present' do
    before do
      allow_any_instance_of(SchoolCompareDecorator).to receive(:ethnicity_data).and_return(ethnicity_data)
      render
    end

    it 'displays the breakdowns and values correctly' do
      ethnicity_data.each do |ethnicity|
        breakdown = ethnicity['breakdown']
        value = ethnicity['school_value'] || 'n/a'
        value = value == 'n/a' ? 'n/a' : "#{value.to_f.round}%"
        expect(rendered).to have_content "#{truncate(breakdown, length: 28)} #{value}"
      end
    end
  end
end