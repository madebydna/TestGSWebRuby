require 'spec_helper'

describe SearchTableConcerns do
  class DummyController < ActionController::Base
    include SearchTableConcerns
  end

  let(:dummy_controller) { DummyController.new }
  let(:dummy_controller2) { DummyController.new }
  let(:dummy_controller3) { DummyController.new }

  let(:array_of_schools) {
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
        :name => 'Growth Proxy State Rating School',
        :subratings => {
          'Academic Progress Rating' => 10
        },
        :remediationData => [{
          "subject" => "All subjects",
          "state_average" => '56%'
        }]
      },
      {
        :name => 'Cowabunga',
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
  let(:array_of_schools2) {
    [
      {
        :name => 'New Proxy Rating School',
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
        :name => 'Proxy Rating School',
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

  before(:each) do
    allow(dummy_controller).to receive(:serialized_schools).and_return(array_of_schools)
    allow(dummy_controller2).to receive(:serialized_schools).and_return(array_of_schools2)
  end

  describe '#growth_progress_rating_header' do
    it 'returns the right header if the state has growth data' do
      expect(dummy_controller.growth_progress_rating_header).to eq('Student Progress Rating')
    end

    it 'returns the right header if the state has growth proxy data' do
      expect(dummy_controller2.growth_progress_rating_header).to eq('Academic Progress Rating')
    end
  end

  describe '#academic_header_names' do
    it 'returns the right academic headers for tableview if the state has growth data' do
      expect(dummy_controller.academic_header_names).to eq(['Test Scores Rating', 'Student Progress Rating', 'College Readiness Rating', 'Advanced Courses Rating', 'Equity Overview Rating'])
    end

    it 'returns the right academic headers for tableview if the state has growth proxy data' do
      expect(dummy_controller2.academic_header_names).to eq(['Test Scores Rating', 'Academic Progress Rating', 'College Readiness Rating', 'Advanced Courses Rating', 'Equity Overview Rating'])
    end
  end

  describe '#generate_remediation_headers' do
    before { allow(dummy_controller3).to receive(:serialized_schools).and_return(empty_array) }

    it 'returns the overall remediation headers for tableview if overall data is present' do
      remediation_header = dummy_controller.generate_remediation_headers
      expect(remediation_header.fetch(:key, nil)).to eq('percentCollegeRemediation')
    end

    it 'returns the english/math remediation headers for tableview if English/Math is present and not overall data' do
      remediation_header = dummy_controller2.generate_remediation_headers
      expect(remediation_header.length)&.to eq(2)
    end

    it 'return nil if there isn\'t instance of overall, math, or english as a remediation subject' do
      remediation_header = dummy_controller3.generate_remediation_headers
      expect(remediation_header)&.to eq(nil)
    end
  end

  describe '#mode' do
    it 'picks the most frequent repeated value' do
      array_of_integers = [77, 77, 89, 77]
      expect(dummy_controller.mode(array_of_integers)).to eq(77)
    end
  end
end