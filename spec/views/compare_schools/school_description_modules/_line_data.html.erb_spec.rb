require 'spec_helper'

describe 'compare_schools/school_description_modules/_line_data.html.erb' do
  let(:no_icon_config) {{
      display_type: 'line_data',
      opt: {
          datapoints: [
              {method: :great_schools_rating, label: 'GreatSchools rating'},
              {method: :test_scores_rating, label: 'Test scores rating'},
              {method: :student_growth_rating, label: 'Student growth rating'},
          ]
      }
  }}
  let(:icon_config) {{
      display_type: 'line_data',
      opt: {
          datapoints: [
              {method: :students_enrolled, label: 'Students enrolled', icon: 'i-16-blue-students-enrolled'},
              {method: :transportation, label: 'Transportation', icon: 'i-16-blue-transportation'},
              {method: :before_care, label: 'Before care', icon: 'i-16-blue-before-care'},
              {method: :after_school, label: 'After school', icon: 'i-16-blue-after-school'}
          ]
      }
  }}
  let(:no_icon_compare_config) { SchoolCompareConfig.new(no_icon_config) }
  let(:icon_compare_config) { SchoolCompareConfig.new(icon_config) }

  let(:school) { FactoryGirl.build(:an_elementary_school) }
  let(:decorated_school) { SchoolCompareDecorator.new(school) }

  before do
    assign(:school, decorated_school)
  end

  context 'when no icons are given' do
    it 'does not display icons' do
      allow(view).to receive(:config) { no_icon_compare_config }

      render

      expect(rendered).to_not have_xpath("//i")
    end
  end

  context 'when icons are given' do
    it 'displays icons' do
      allow(view).to receive(:config) { icon_compare_config }

      render

      icon_compare_config.opt[:datapoints].each do |datapoint|
        expect(rendered).to have_selector("i.iconx16.#{datapoint[:icon]}")
      end
    end
  end
end