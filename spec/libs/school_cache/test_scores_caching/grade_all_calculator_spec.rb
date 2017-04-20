require 'spec_helper'

describe 'GradeAllCalculator' do

  describe '#inject_grade_all' do
    let (:calculator) { TestScoresCaching::GradeAllCalculator.new(test_scores) }
    let (:new_data_sets) { calculator.inject_grade_all }
    subject { new_data_sets.find { |ds| ds.grade == 'All' } }

    context 'with two subgroup data sets that have grade-level data' do
      let(:test_scores) do
        [
            OpenStruct.new({
                               data_type_id: 1,
                               grade: '9',
                               year: 2015,
                               subject_id: 4,
                               breakdown_id: 4,
                               level_code: 'e,m,h',
                               school_value_float: 10,
                               state_value_float: 50,
                               number_students_tested: 4,
                               state_number_tested: 2,
                           }).freeze,
            OpenStruct.new({
                               data_type_id: 1,
                               grade: '10',
                               year: 2015,
                               subject_id: 4,
                               breakdown_id: 4,
                               level_code: 'e,m,h',
                               school_value_float: 20,
                               state_value_float: 100,
                               number_students_tested: 8,
                               state_number_tested: 3,
                           }).freeze
        ].freeze
      end

      it { is_expected.to be_present }
      its(:school_value_float) { is_expected.to eq(16.67) }
      its(:state_value_float) { is_expected.to eq(80) }
      its(:number_students_tested) { is_expected.to eq(12) }
      its(:state_number_tested) { is_expected.to eq(5) }
      its(:subject_id) { is_expected.to eq(4) }
      its(:data_type_id) { is_expected.to eq(1) }
      its(:breakdown_id) { is_expected.to eq(4) }
      its(:level_code) { is_expected.to eq('e,m,h') }
    end

    context 'with subgroup data sets that already include all grades' do
      let(:test_scores) do
        [
            OpenStruct.new({
                               data_type_id: 1,
                               grade: '9',
                               year: 2015,
                               subject_id: 4,
                               breakdown_id: 4,
                               level_code: 'e,m,h',
                               school_value_float: 10,
                               state_value_float: 50,
                               number_students_tested: 4,
                               state_number_tested: 2,
                           }).freeze,
            OpenStruct.new({
                               data_type_id: 1,
                               grade: '10',
                               year: 2015,
                               subject_id: 4,
                               breakdown_id: 4,
                               level_code: 'e,m,h',
                               school_value_float: 20,
                               state_value_float: 100,
                               number_students_tested: 8,
                               state_number_tested: 3,
                           }).freeze,
            OpenStruct.new({
                               data_type_id: 1,
                               grade: 'All',
                               year: 2015,
                               subject_id: 4,
                               breakdown_id: 4,
                               level_code: 'e,m,h',
                               school_value_float: 16.67,
                               state_value_float: 80,
                               number_students_tested: 12,
                               state_number_tested: 5,
                           }).freeze
        ].freeze
      end

      it { is_expected.to be(test_scores.find { |ds| ds.grade == 'All' }) }
    end
  end

  describe '#calculate_grade_all' do
    let(:grade_all_tds) do
      OpenStruct.new(TestScoresCaching::GradeAllCalculator.new.calculate_grade_all(test_scores))
    end
    subject { grade_all_tds }

    context 'with two data sets that have all data' do
      let(:test_scores) do 
        [
          OpenStruct.new({
            data_type_id: 1,
            grade: '9',
            year: 2015,
            subject_id: 4,
            breakdown_id: 0,
            level_code: 'e,m,h',
            school_value_float: 10,
            state_value_float: 50,
            number_students_tested: 4,
            state_number_tested: 2,
          }).freeze,
          OpenStruct.new({
            data_type_id: 1,
            grade: '10',
            year: 2015,
            subject_id: 4,
            breakdown_id: 0,
            level_code: 'e,m,h',
            school_value_float: 20,
            state_value_float: 100,
            number_students_tested: 8,
            state_number_tested: 3,
          }).freeze
        ].freeze
      end

      it { is_expected.to be_present }
      its(:school_value_float) { is_expected.to eq(16.67) }
      its(:state_value_float) { is_expected.to eq(80) }
      its(:number_students_tested) { is_expected.to eq(12) }
      its(:state_number_tested) { is_expected.to eq(5) }
      its(:subject_id) { is_expected.to eq(4) }
      its(:data_type_id) { is_expected.to eq(1) }
      its(:breakdown_id) { is_expected.to eq(0) }
      its(:level_code) { is_expected.to eq('e,m,h') }
    end

    context 'when a school_value_float is actually a string' do
      let(:test_scores) do 
        [
          OpenStruct.new({
            data_type_id: 1,
            grade: '9',
            year: 2015,
            subject_id: 4,
            breakdown_id: 0,
            level_code: 'e,m,h',
            school_value_float: 10,
            state_value_float: '<50%',
            number_students_tested: 4,
            state_number_tested: 2,
          }).freeze,
          OpenStruct.new({
            data_type_id: 1,
            grade: '10',
            year: 2015,
            subject_id: 4,
            breakdown_id: 0,
            level_code: 'e,m,h',
            school_value_float: 20,
            state_value_float: 100,
            number_students_tested: 8,
            state_number_tested: 3,
          }).freeze
        ].freeze
      end

      it { is_expected.to be_present }
      its(:school_value_float) { is_expected.to eq(16.67) }
      its(:state_value_float) { is_expected.to eq(80) }
      its(:number_students_tested) { is_expected.to eq(12) }
      its(:state_number_tested) { is_expected.to eq(5) }
      its(:subject_id) { is_expected.to eq(4) }
      its(:data_type_id) { is_expected.to eq(1) }
      its(:breakdown_id) { is_expected.to eq(0) }
      its(:level_code) { is_expected.to eq('e,m,h') }
    end

    context 'with a data set that is missing number of students tested' do
      let(:test_scores) do 
        [
          OpenStruct.new({
            data_type_id: 1,
            grade: '9',
            year: 2015,
            subject_id: 4,
            school_value_float: 10,
            state_value_float: 50,
            number_students_tested: 4,
            state_number_tested: 4,
          }).freeze,
          OpenStruct.new({
            data_type_id: 1,
            grade: '10',
            year: 2015,
            subject_id: 4,
            school_value_float: 20,
            state_value_float: 100
          }).freeze
        ].freeze
      end

      it { is_expected.to be_present }
      its(:school_value_float) { is_expected.to eq(10) }
      its(:state_value_float) { is_expected.to eq(50) }
      its(:number_students_tested) { is_expected.to eq(4) }
      its(:state_number_tested) { is_expected.to eq(4) }
      its(:subject_id) { is_expected.to eq(4) }
    end

    context 'with a data set that is missing school value' do
      let(:test_scores) do 
        [
          OpenStruct.new({
            data_type_id: 1,
            grade: '9',
            year: 2015,
            subject_id: 4,
            state_value_float: 50,
            number_students_tested: 4,
            state_number_tested: 4,
          }).freeze,
          OpenStruct.new({
            data_type_id: 1,
            grade: '10',
            year: 2015,
            subject_id: 4,
            school_value_float: 20,
            state_value_float: 100,
            number_students_tested: 8,
            state_number_tested: 8,
          }).freeze
        ].freeze
      end

      it { is_expected.to be_present }
      its(:school_value_float) { is_expected.to eq(20) }
      its(:state_value_float) { is_expected.to eq(83.33) }
      its(:number_students_tested) { is_expected.to eq(8) }
      its(:state_number_tested) { is_expected.to eq(12) }
      its(:subject_id) { is_expected.to eq(4) }
    end

    context 'when one number of students tested is zero for a test' do
      let(:test_scores) do 
        [
          OpenStruct.new({
            data_type_id: 1,
            grade: '9',
            year: 2015,
            subject_id: 4,
            school_value_float: 10,
            state_value_float: 50,
            number_students_tested: 0,
            state_number_tested: 4,
          }).freeze,
          OpenStruct.new({
            data_type_id: 1,
            grade: '10',
            year: 2015,
            subject_id: 4,
            school_value_float: 20,
            state_value_float: 100,
            number_students_tested: 8,
            state_number_tested: 0,
          }).freeze
        ].freeze
      end

      it { is_expected.to be_present }
      its(:school_value_float) { is_expected.to eq(20) }
      its(:state_value_float) { is_expected.to eq(50) }
      its(:number_students_tested) { is_expected.to eq(8) }
      its(:state_number_tested) { is_expected.to eq(4) }
    end

    context 'when there are no number of students tested for any test' do
      let(:test_scores) do 
        [
          OpenStruct.new({
            data_type_id: 1,
            grade: '9',
            year: 2015,
            subject_id: 4,
            school_value_float: 10,
            state_value_float: 50,
            number_students_tested: 0,
            state_number_tested: 4,
          }).freeze,
          OpenStruct.new({
            data_type_id: 1,
            grade: '10',
            year: 2015,
            subject_id: 4,
            school_value_float: 20,
            state_value_float: 100,
            number_students_tested: 0,
            state_number_tested: 8,
          }).freeze
        ].freeze
      end

      it { is_expected.to be_present }
      its(:school_value_float) { is_expected.to eq(nil) }
      its(:state_value_float) { is_expected.to eq(83.33) }
      its(:number_students_tested) { is_expected.to eq(0) }
      its(:state_number_tested) { is_expected.to eq(12) }
    end

    context 'with two data sets that already contain grade all' do
      let(:test_scores) do 
        [
          OpenStruct.new({
            data_type_id: 1,
            grade: 'All',
            year: 2015,
            subject_id: 4 
          }).freeze,
          OpenStruct.new({
            data_type_id: 1,
            grade: '10',
            year: 2015,
            subject_id: 4
          }).freeze
        ].freeze
      end

      it 'should raise an ArgumentError' do
        expect { subject }.to raise_error(ArgumentError)
      end
    end
  end

end

