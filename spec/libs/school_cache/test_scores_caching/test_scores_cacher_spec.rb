require 'spec_helper'

describe TestScoresCaching::TestScoresCacher do
  let(:school) { FactoryGirl.build(:alameda_high_school) }
  let(:test_scores_cacher) { TestScoresCaching::TestScoresCacher.new(school) }

  describe '#add_lowest_grade_to_hash' do
    let(:hash) do
      {
        1 => {
          test_label: 'a label',
          test_source: 'a source',
          test_description: 'a description',
          grades: {
            3 => {},
            2 => {},
            4 => {}
          }
        }
      }
    end

    it 'should add lowest grade to each data type hash' do
      expected = {
        1 => {
          test_label: 'a label',
          test_source: 'a source',
          test_description: 'a description',
          grades: {
            3 => {},
            2 => {},
            4 => {}
          },
          lowest_grade: 2
        }
      }
      expect(test_scores_cacher.add_lowest_grade_to_hash(hash))
        .to eq(expected)
    end

  end

  describe '#inject_grade_all' do
    let(:resulting_data_sets) do
      test_scores_cacher.
        inject_grade_all(test_scores)
    end
    let(:grade_all_tds) do
      resulting_data_sets.find { |ts| ts.grade == 'All' }
    end

    context 'with two data sets that differ by grade' do
      let(:test_scores) do 
        [
          OpenStruct.new({
            data_type_id: 1,
            grade: '9',
            year: 2015,
            subject: 'Science',
            breakdown_id: 1,
            school_value_float: 10,
            state_value_float: 50,
            number_students_tested: 4,
            state_number_tested: 2,
          }).freeze,
          OpenStruct.new({
            data_type_id: 1,
            grade: '10',
            year: 2015,
            subject: 'Science',
            breakdown_id: 1,
            school_value_float: 20,
            state_value_float: 100,
            number_students_tested: 8,
            state_number_tested: 3,
          }).freeze
        ].freeze
      end

      describe 'the data sets that the method returns' do
        subject { resulting_data_sets }
        its(:length) { is_expected.to eq(3) }
      end
      describe 'grade ALL test data set' do
        subject { grade_all_tds }
        it { is_expected.to be_present }
        its(:state_value_float) { is_expected.to eq(80) }
        its(:school_value_float) { is_expected.to round_to(16.67, 2) }
        its(:number_students_tested) { is_expected.to eq(12) }
        its(:state_number_tested) { is_expected.to eq(5) }
        its(:subject) { is_expected.to eq('Science') }
      end
    end

    context 'with data sets having differing years' do
      let(:test_scores) do 
        [
          OpenStruct.new({
            data_type_id: 1,
            grade: '9',
            year: 2015,
            subject: 'Science',
            breakdown_id: 1,
            school_value_float: 10,
            state_value_float: 50,
            number_students_tested: 4,
            state_number_tested: 2,
          }).freeze,
          OpenStruct.new({
            data_type_id: 1,
            grade: '10',
            year: 2015,
            subject: 'Science',
            breakdown_id: 1,
            school_value_float: 20,
            state_value_float: 100,
            number_students_tested: 8,
            state_number_tested: 3,
          }).freeze,
          OpenStruct.new({
            data_type_id: 1,
            grade: '8',
            year: 2014,
            subject: 'Math',
            breakdown_id: 1,
            school_value_float: 20,
            state_value_float: 100,
            number_students_tested: 8,
            state_number_tested: 3,
          }).freeze
        ].freeze
      end

      describe 'the data sets that the method returns' do
        subject { resulting_data_sets }
        its(:length) { is_expected.to eq(4) }
      end
      describe 'grade ALL test data set' do
        subject { grade_all_tds }
        it { is_expected.to be_present }
        its(:state_value_float) { is_expected.to eq(80) }
        its(:school_value_float) { is_expected.to round_to(16.67, 2) }
        its(:number_students_tested) { is_expected.to eq(12) }
        its(:state_number_tested) { is_expected.to eq(5) }
        its(:subject) { is_expected.to eq('Science') }
      end
    end

    context 'with two data sets that already contain grade all' do
      let(:test_scores) do 
        [
          OpenStruct.new({
            data_type_id: 1,
            grade: 'All',
            year: 2015,
            subject: 'Science'
          }).freeze,
          OpenStruct.new({
            data_type_id: 1,
            grade: '10',
            year: 2015,
            subject: 'Science'
          }).freeze
        ].freeze
      end

      describe 'the data sets that the method returns' do
        subject { resulting_data_sets }
        its(:length) { is_expected.to eq(2) }
      end
    end
  end
end

