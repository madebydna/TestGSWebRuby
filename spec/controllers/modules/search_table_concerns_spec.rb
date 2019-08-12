require 'spec_helper'

describe SearchTableConcerns do
  class DummyController < ActionController::Base
    include SearchTableConcerns
  end

  let(:dummy_controller) { DummyController.new }

  let(:array_of_growth_data_state_and_all_subjects_remediation_schools) {
    [
      {
        :name => 'Growth Data State Rating School',
        :subratings => {
          'Student Progress Rating' => 7
        },
        :remediationData => [{
          "subject" => "All subjects",
          "state_average" => '77%'
        }]
      },
      {
        :name => 'Growth Proxy State Rating School That Shouldn\'t Be here',
        :subratings => {
          'Academic Progress Rating' => 10
        },
        :remediationData => [{
          "subject" => "All subjects",
          "state_average" => '56%'
        }]
      },
      {
        :name => 'Another Growth Data State School with Outlier Remediation Data',
        :subratings => {
          'Student Progress Rating' => 6
        },
        :remediationData => [{
          "subject" => "English",
          "state_average" => '76%'
        }]
      }
    ]
  }
  let(:array_of_growth_proxy_state_and_specific_subjects_remediation_schools) {
    [
      {
        :name => 'Proxy Rating School',
        :subratings => {
          'Academic Progress Rating' => 7
        },
        :remediationData => 
          [
            {
              "subject" => "English",
              "state_average" => '76%'
            },
            {
              "subject" => "Math",
              "state_average" => '35%'
            }
        ]
      },
      {
        :name => 'New Proxy Rating School',
        :subratings => {
          'Academic Progress Rating' => 10
        },
        :remediationData => 
          [
            {
              "subject" => "English",
              "state_average" => '33%'
            },
            {
              "subject" => "Math",
              "state_average" => '32%'
            }
        ]
      },
      {
        :name => 'Cow\'s Slick County',
        :subratings => {
          'Academic Progress Rating' => 6
        },
        :remediationData => [{
          "subject" => "English",
          "state_average" => '56%'
        }]
      }
    ]
  }
  let(:empty_array) {[]}

  describe 'Cache Data for a Growth Data State with All Subjects Data for Remediation' do
    before {allow(dummy_controller).to receive(:serialized_schools).and_return(array_of_growth_data_state_and_all_subjects_remediation_schools)}
    it 'returns the right header for #growth_progress_rating_header' do
      expect(dummy_controller.growth_progress_rating_header).to eq('Student Progress Rating')
    end

    it 'returns the right header for #academic_header_names' do
      expect(dummy_controller.academic_header_names).to eq(['Test Scores Rating', 'Student Progress Rating', 'College Readiness Rating', 'Advanced Courses Rating', 'Equity Overview Rating'])
    end

    it 'returns the overall remediation headers for tableview if overall data is present' do
      remediation_header = dummy_controller.generate_remediation_headers
      expect(remediation_header.fetch(:key, nil)).to eq('percentCollegeRemediation')
    end
  end

  describe 'Cache Data for a Growth Proxy Data State with Math/Reading Data for Remediation' do
    before {allow(dummy_controller).to receive(:serialized_schools).and_return(array_of_growth_proxy_state_and_specific_subjects_remediation_schools)}
    it 'returns the right header for #growth_progress_rating_header' do
      expect(dummy_controller.growth_progress_rating_header).to eq('Academic Progress Rating')
    end

    it 'returns the right header for #academic_header_names' do
      expect(dummy_controller.academic_header_names).to eq(['Test Scores Rating', 'Academic Progress Rating', 'College Readiness Rating', 'Advanced Courses Rating', 'Equity Overview Rating'])
    end

    it 'returns the english/math remediation headers for tableview if English/Math is present and not overall data' do
      remediation_header = dummy_controller.generate_remediation_headers
      expect(remediation_header.length).to eq(2)
      expect(remediation_header.map {|x| x.fetch(:key, nil)}).to eq(['percentCollegeRemediationEnglish','percentCollegeRemediationMath'])
    end
  end

  describe 'handles the null case' do
    before { allow(dummy_controller).to receive(:serialized_schools).and_return(empty_array) }

    it 'return nil if there isn\'t instance of overall, math, or english as a remediation subject' do
      remediation_header = dummy_controller.generate_remediation_headers
      expect(remediation_header).to be_nil
    end
  end

  describe '#mode' do
    subject {dummy_controller.mode(input_array)}

    context 'with an array of numbers' do
      let(:input_array) {[77, 77, 89, 77]}
      it { is_expected.to eq(77) }
    end

    context 'with an array of words' do
      let(:input_array) {%w(cat dog cat mouse)}
      it { is_expected.to eq('cat')}
    end
  end
end