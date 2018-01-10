require 'spec_helper'
require_relative '../../../helpers/school_with_cache_helper'

RSpec.configure do |c|
  c.include CompareSchoolsConcerns
end

describe 'compare_schools/school_description_modules/_line_data.html.erb' do
  let(:no_icon_config) {{
      display_type: 'line_data',
      opt: {
          datapoints: [
              {method: :students_enrolled, label: 'Students enrolled'},
              {method: :transportation, label: 'Transportation'},
              {method: :before_care, label: 'Before care'},
              {method: :after_school, label: 'After school'}
          ]
      }
  }}
  let(:icon_config) {{
      display_type: 'line_data',
      opt: {
          datapoints: [
              {method: :students_enrolled, label: 'Students enrolled', icon: 'iconx16 i-16-blue-students-enrolled'},
              {method: :transportation, label: 'Transportation', icon: 'iconx16 i-16-blue-transportation'},
              {method: :before_care, label: 'Before care', icon: 'iconx16 i-16-blue-before-care'},
              {method: :after_school, label: 'After school', icon: 'iconx16 i-16-blue-after-school'}
          ]
      }
  }}
  let(:ethnicity_config) {{
      display_type: 'line_data',
      opt: {
          datapoints: [
              {method: :school_ethnicity, argument: 'Schoolstate val brkdwn', label: 'Schoolstate val brkdwn', icon: 'fl square js-comparePieChartSquare'},
              {method: :school_ethnicity, argument: 'Another valid breakdown', label: 'Another valid breakdown', icon: 'fl square js-comparePieChartSquare'},
              {method: :school_ethnicity, argument: 'No state value breakdown', label: 'No state value breakdown', icon: 'fl square js-comparePieChartSquare'},
              {method: :school_ethnicity, argument: 'Zero valued breakdown', label: 'Zero valued breakdown', icon: 'fl square js-comparePieChartSquare'}
          ]
      }
  }}
  let(:ethnicity_data) {[
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
       'breakdown'=>'Zero valued breakdown',
       'school_value'=>0.0,
       'state_average'=>0.0}
  ]}
  let(:no_icon_compare_config) { SchoolCompareConfig.new(no_icon_config) }
  let(:icon_compare_config) { SchoolCompareConfig.new(icon_config) }
  let(:ethnicity_compare_config) { SchoolCompareConfig.new(ethnicity_config) }

  init_school_with_cache

  let(:decorated_school) { SchoolCompareDecorator.new(school_with_cache) }

  before do
    assign(:school, decorated_school)
  end

  context 'when no icons are given' do
    it 'does not display icons' do
      allow(view).to receive(:config) { no_icon_compare_config }

      render

      expect(rendered).to_not have_xpath("td/i")
    end
  end

  context 'when icons are given' do
    it 'displays icons' do
      allow(view).to receive(:config) { icon_compare_config }

      render

      icon_compare_config.opt[:datapoints].each do |datapoint|
        expect(rendered).to have_selector("i.#{datapoint[:icon].gsub(' ','.')}")
      end
    end
  end

  context 'when no ethnicity data are present' do
    before do
      allow(decorated_school.school_cache).to receive(:ethnicity_data).and_return([])
      instance_variable_set('@schools', [decorated_school])
      prep_school_ethnicity_data!
      allow(view).to receive(:config) { ethnicity_compare_config }
      render
    end

    it 'displays NO_ETHNICITY_SYMBOL for all breakdowns' do
      ethnicity_data.each do |ethnicity|
        breakdown = ethnicity['breakdown']
        expect(rendered).to have_content "#{truncate(breakdown, length: 26)} #{CachedCharacteristicsMethods::NO_ETHNICITY_SYMBOL}"
      end
    end
  end

  context 'when ethnicity data is present' do
    before do
      allow(decorated_school.school_cache).to receive(:ethnicity_data).and_return(ethnicity_data)
      instance_variable_set('@schools', [decorated_school])
      prep_school_ethnicity_data!
      allow(view).to receive(:config) { ethnicity_compare_config }
      render
    end

    it 'displays the breakdowns and values correctly' do
      ethnicity_data.each do |ethnicity|
        breakdown = ethnicity['breakdown']
        value = ethnicity['school_value'] || CachedCharacteristicsMethods::NO_ETHNICITY_SYMBOL
        value = "#{value.to_f.round}%" unless value == CachedCharacteristicsMethods::NO_ETHNICITY_SYMBOL
        if value != '0%'
          expect(rendered).to have_content "#{truncate(breakdown, length: 26)} #{value}"
        else
          expect(rendered).to have_content "#{truncate(breakdown, length: 26)} <1%"
        end
      end
    end
  end
end