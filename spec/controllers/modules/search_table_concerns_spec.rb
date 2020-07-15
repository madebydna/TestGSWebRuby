require 'spec_helper'

describe SearchTableConcerns do
  class DummyController < ActionController::Base
    attr_accessor :state
    include SearchTableConcerns
  end

  after do
    clean_dbs :gs_schooldb
  end

  let(:dummy_controller) { DummyController.new }

  let(:array_of_growth_data_state_and_all_subjects_remediation_schools) {
    [
      {
        name: 'Growth Data State Rating School',
        remediationData: [{
          "subject" => "All subjects",
          "state_average" => '77%'
        }]
      },
      {
        name: 'Growth Proxy State Rating School That Shouldn\'t Be here',
        remediationData: [{
          "subject" => "All subjects",
          "state_average" => '56%'
        }]
      },
      {
        name: 'Another Growth Data State School with Outlier Remediation Data',
        remediationData: [{
          "subject" => "English",
          "state_average" => '76%'
        }]
      }
    ]
  }
  let(:array_of_growth_proxy_state_and_specific_subjects_remediation_schools) {
    [
      {
        name: 'Proxy Rating School',
        remediationData: 
          [
            {
              "subject" => "English",
              "state_average" => '76%'
            },
            {
              "subject" => "Math",
              "state_average" => '35%'
            }
        ],
        state: 'ca'
      },
      {
        name: 'New Proxy Rating School',
        remediationData: 
          [
            {
              "subject" => "English",
              "state_average" => '33%'
            },
            {
              "subject" => "Math",
              "state_average" => '32%'
            }
        ],
        state: 'ar'
      },
      {
        name: 'Cow\'s Slick County',
        remediationData: [{
          "subject" => "English",
          "state_average" => '56%'
        }],
        state: 'ca'
      }
    ]
  }
  let(:empty_array) {[]}

  before do
    FactoryBot.create(:state_cache, state: 'ca', name: 'state_attributes', value: "{\"growth_type\":\"Academic Progress Rating\"}")
    FactoryBot.create(:state_cache, state: 'ar', name: 'state_attributes', value: "{\"growth_type\":\"Student Progress Rating\"}")
  end

  describe 'Remediation headers for tableview' do

    it 'returns the overall remediation headers for tableview if overall data is present' do
      allow(dummy_controller).to receive(:serialized_schools).and_return(array_of_growth_data_state_and_all_subjects_remediation_schools)
      remediation_header = dummy_controller.generate_remediation_headers
      expect(remediation_header.fetch(:key, nil)).to eq('percentCollegeRemediation')
    end

    it 'returns the english/math remediation headers for tableview if English/Math is present and not overall remediation data' do
      allow(dummy_controller).to receive(:serialized_schools).and_return(array_of_growth_proxy_state_and_specific_subjects_remediation_schools)
      remediation_header = dummy_controller.generate_remediation_headers
      expect(remediation_header.length).to eq(2)
      expect(remediation_header.map {|x| x.fetch(:key, nil)}).to eq(['percentCollegeRemediationEnglish','percentCollegeRemediationMath'])
    end

      it 'return nil if there isn\'t instance of overall, math, or english as a remediation subject' do
      allow(dummy_controller).to receive(:serialized_schools).and_return(empty_array)
      remediation_header = dummy_controller.generate_remediation_headers
      expect(remediation_header).to be_nil
    end
  end

  describe 'Student Progress / Academic Progress Rating Headers' do
    context 'when a state is a data growth state' do
      before(:each) do
        allow(dummy_controller).to receive(:state).and_return('ar')
      end

      it '#growth_data_proxy_state?' do
        expect(dummy_controller.growth_data_proxy_state?).to be false
      end

      it '#growth_progress_rating_header' do
        expect(dummy_controller.growth_progress_rating_header).to eq('Student Progress Rating')
      end

      it '#academic_header_names' do
        expect(dummy_controller.academic_header_names).to eq(['Test Scores Rating', 'Student Progress Rating', 'College Readiness Rating', 'Equity Overview Rating'])
      end
    end

    context 'when a state is a data growth proxy state' do
      before(:each) do 
        allow(dummy_controller).to receive(:state).and_return('ca')
      end

      it '#growth_data_proxy_state?' do
        expect(dummy_controller.growth_data_proxy_state?).to be true
      end

      it '#growth_progress_rating_header' do
        expect(dummy_controller.growth_progress_rating_header).to eq('Academic Progress Rating')
      end

      it '#academic_header_names' do
        expect(dummy_controller.academic_header_names).to eq(['Test Scores Rating', 'Academic Progress Rating', 'College Readiness Rating', 'Equity Overview Rating'])
      end
    end

    context 'when no state is established at the controller level' do
      before(:each) do 
        allow(dummy_controller).to receive(:serialized_schools).and_return(array_of_growth_proxy_state_and_specific_subjects_remediation_schools)
      end

      it '#growth_data_proxy_state?' do
        expect(dummy_controller.growth_data_proxy_state?).to be true
      end

      it '#growth_progress_rating_header' do
        expect(dummy_controller.growth_progress_rating_header).to eq('Academic Progress Rating')
      end

      it '#academic_header_names' do
        expect(dummy_controller.academic_header_names).to eq(['Test Scores Rating', 'Academic Progress Rating', 'College Readiness Rating', 'Equity Overview Rating'])
      end
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

  describe '#table_headers' do
    it 'return compare table headers if proper params are detected' do
      allow(dummy_controller).to receive(:breakdown).and_return('Dummy')
      expect(dummy_controller).to receive(:compare_schools_table_headers)
      dummy_controller.table_headers
    end

    it 'return search table headers' do
      allow(dummy_controller).to receive(:breakdown).and_return(nil)
      allow(dummy_controller).to receive(:serialized_schools).and_return(["Schools", "Too", "Cool"])
      expect(dummy_controller).to receive(:overview_header_hash)
      expect(dummy_controller).to receive(:equity_header_hash).with(["Schools", "Too", "Cool"])
      expect(dummy_controller).to receive(:academic_header_hash)
      dummy_controller.table_headers
    end
  end
end