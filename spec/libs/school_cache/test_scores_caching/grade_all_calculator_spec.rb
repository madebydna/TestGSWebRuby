# frozen_string_literal: true

require 'spec_helper'

describe 'GradeAllCalculator' do

  describe '#inject_grade_all' do
    let (:calculator) { TestScoresCaching::GradeAllCalculator.new(test_scores) }
    let (:new_data_sets) { calculator.inject_grade_all }
    subject { new_data_sets.find { |ds| ds.grade == 'All' } }

    context 'with two subgroup data sets that have grade-level data' do
      let(:test_scores) do
        GsdataCaching::GsDataValue.from_array_of_hashes([
            OpenStruct.new({
                               data_type: 1,
                               grade: '9',
                               year: 2015,
                               breakdowns: '4',
                               school_value: 10,
                               state_value: 50,
                               school_cohort_count: 4,
                               state_cohort_count: 2,
                           }).freeze,
            OpenStruct.new({
                               data_type: 1,
                               grade: '10',
                               year: 2015,
                               breakdowns: '4',
                               school_value: 20,
                               state_value: 100,
                               school_cohort_count: 8,
                               state_cohort_count: 3,
                           }).freeze
        ]).freeze
      end

      it { is_expected.to be_present }
      its(:school_value) { is_expected.to eq(16.67) }
      its(:state_value) { is_expected.to eq(80) }
      its(:school_cohort_count) { is_expected.to eq(12) }
      its(:state_cohort_count) { is_expected.to eq(5) }
      its(:data_type) { is_expected.to eq(1) }
      its(:breakdowns) { is_expected.to eq(['4']) }
    end

    context 'with subgroup data sets that already include all grades' do
      let(:test_scores) do
        GsdataCaching::GsDataValue.from_array_of_hashes([
            OpenStruct.new({
                               data_type: 1,
                               grade: '9',
                               year: 2015,
                               breakdowns: '4',
                               school_value: 10,
                               state_value: 50,
                               school_cohort_count: 4,
                               state_cohort_count: 2,
                           }).freeze,
            OpenStruct.new({
                               data_type: 1,
                               grade: '10',
                               year: 2015,
                               breakdowns: '4',
                               school_value: 20,
                               state_value: 100,
                               school_cohort_count: 8,
                               state_cohort_count: 3,
                           }).freeze,
            OpenStruct.new({
                               data_type: 1,
                               grade: 'All',
                               year: 2015,
                               breakdowns: '4',
                               school_value: 16.67,
                               state_value: 80,
                               school_cohort_count: 12,
                               state_cohort_count: 5,
                           }).freeze
        ]).freeze
      end

      it { is_expected.to be(test_scores.find { |ds| ds.grade == 'All' }) }
    end
  end

  describe '#calculate_grade_all' do
    let(:grade_all_tds) do
      TestScoresCaching::GradeAllCalculator.new.send(:calculate_grade_all, test_scores)
    end
    subject { grade_all_tds }

    context 'with two data sets that have all data' do
      let(:test_scores) do 
        GsdataCaching::GsDataValue.from_array_of_hashes([
          OpenStruct.new({
            data_type: 1,
            grade: '9',
            year: 2015,
            breakdowns: '0',
            school_value: 10,
            state_value: 50,
            school_cohort_count: 4,
            state_cohort_count: 2,
          }).freeze,
          OpenStruct.new({
            data_type: 1,
            grade: '10',
            year: 2015,
            breakdowns: '0',
            school_value: 20,
            state_value: 100,
            school_cohort_count: 8,
            state_cohort_count: 3,
          }).freeze
        ]).freeze
      end

      it { is_expected.to be_present }
      its(:school_value) { is_expected.to eq(16.67) }
      its(:state_value) { is_expected.to eq(80) }
      its(:school_cohort_count) { is_expected.to eq(12) }
      its(:state_cohort_count) { is_expected.to eq(5) }
      its(:data_type) { is_expected.to eq(1) }
      its(:breakdowns) { is_expected.to eq(['0']) }
    end

    context 'when a state_value is actually a string' do
      let(:test_scores) do 
        GsdataCaching::GsDataValue.from_array_of_hashes([
          OpenStruct.new({
            data_type: 1,
            grade: '9',
            year: 2015,
            breakdowns: '0',
            school_value: 10,
            state_value: '<50%',
            school_cohort_count: 4,
            state_cohort_count: 2,
          }).freeze,
          OpenStruct.new({
            data_type: 1,
            grade: '10',
            year: 2015,
            breakdowns: '0',
            school_value: 20,
            state_value: 100,
            school_cohort_count: 8,
            state_cohort_count: 3,
          }).freeze
        ]).freeze
      end

      it { is_expected.to be_present }
      its(:school_value) { is_expected.to eq(16.67) }
      its(:state_value) { is_expected.to eq(nil) }
      its(:school_cohort_count) { is_expected.to eq(12) }
      its(:state_cohort_count) { is_expected.to eq(nil) }
      its(:data_type) { is_expected.to eq(1) }
      its(:breakdowns) { is_expected.to eq(['0']) }
    end

    context 'with a data set that is missing number of students tested' do
      let(:test_scores) do 
        GsdataCaching::GsDataValue.from_array_of_hashes([
          OpenStruct.new({
            data_type: 1,
            grade: '9',
            year: 2015,
            school_value: 10,
            state_value: 50,
            school_cohort_count: 4,
            state_cohort_count: 4,
          }).freeze,
          OpenStruct.new({
            data_type: 1,
            grade: '10',
            year: 2015,
            school_value: 20,
            state_value: 100
          }).freeze
        ]).freeze
      end

      it { is_expected.to be_present }
      its(:school_value) { is_expected.to eq(15) }
      its(:state_value) { is_expected.to eq(75) }
      its(:school_cohort_count) { is_expected.to be_nil }
      its(:state_cohort_count) { is_expected.to be_nil }
    end

    context 'with a data set that is missing school value' do
      let(:test_scores) do 
        GsdataCaching::GsDataValue.from_array_of_hashes([
          OpenStruct.new({
            data_type: 1,
            grade: '9',
            year: 2015,
            state_value: 50,
            school_cohort_count: 4,
            state_cohort_count: 4,
          }).freeze,
          OpenStruct.new({
            data_type: 1,
            grade: '10',
            year: 2015,
            school_value: 20,
            state_value: 100,
            school_cohort_count: 8,
            state_cohort_count: 8,
          }).freeze
        ]).freeze
      end

      it { is_expected.to be_present }
      its(:school_value) { is_expected.to eq(nil) }
      its(:state_value) { is_expected.to eq(83.33) }
      its(:school_cohort_count) { is_expected.to eq(nil) }
      its(:state_cohort_count) { is_expected.to eq(12) }
    end

    context 'with all data sets missing state value' do
      let(:test_scores) do
        GsdataCaching::GsDataValue.from_array_of_hashes([
          OpenStruct.new({
            data_type: 1,
            grade: '9',
            year: 2015,
            school_value: 10,
            school_cohort_count: 4,
            state_cohort_count: 4,
          }).freeze,
          OpenStruct.new({
            data_type: 1,
            grade: '10',
            year: 2015,
            school_value: 20,
            school_cohort_count: 8,
            state_cohort_count: 8,
          }).freeze
        ]).freeze
      end

      it { is_expected.to be_present }
      its(:school_value) { is_expected.to eq(16.67) }
      its(:school_cohort_count) { is_expected.to eq(12) }
      its(:state_value) { is_expected.to be_nil }
    end

    context 'with all data sets missing school value' do
      let(:test_scores) do
        GsdataCaching::GsDataValue.from_array_of_hashes([
          OpenStruct.new({
            data_type: 1,
            grade: '9',
            year: 2015,
            state_value: 50,
            school_cohort_count: 4,
            state_cohort_count: 4,
          }).freeze,
          OpenStruct.new({
            data_type: 1,
            grade: '10',
            year: 2015,
            state_value: 100,
            school_cohort_count: 8,
            state_cohort_count: 8,
          }).freeze
        ]).freeze
      end

      it { is_expected.to be_present }
      its(:school_value) { is_expected.to be_nil }
      its(:state_value) { is_expected.to eq(83.33) }
      its(:state_cohort_count) { is_expected.to eq(12) }
    end

    context 'with all data sets are missing values and number_tested' do
      let(:test_scores) do
        GsdataCaching::GsDataValue.from_array_of_hashes([
          OpenStruct.new({
            data_type: 1,
            grade: '9',
            year: 2015,
          }).freeze,
          OpenStruct.new({
            data_type: 1,
            grade: '10',
            year: 2015,
          }).freeze
        ]).freeze
      end

      it 'returns nil' do
        expect(subject.to_h).to be_empty
      end
    end

    context 'when one number of students tested is zero for a test' do
      let(:test_scores) do 
        GsdataCaching::GsDataValue.from_array_of_hashes([
          OpenStruct.new({
            data_type: 1,
            grade: '9',
            year: 2015,
            school_value: 10,
            state_value: 50,
            school_cohort_count: 0,
            state_cohort_count: 4,
          }).freeze,
          OpenStruct.new({
            data_type: 1,
            grade: '10',
            year: 2015,
            school_value: 20,
            state_value: 100,
            school_cohort_count: 8,
            state_cohort_count: 0,
          }).freeze
        ]).freeze
      end

      it { is_expected.to be_present }
      its(:school_value) { is_expected.to eq(15) }
      its(:state_value) { is_expected.to eq(75) }
      its(:school_cohort_count) { is_expected.to be_nil }
      its(:state_cohort_count) { is_expected.to be_nil }
    end

    context 'when one number of students tested is missing for a test' do
      let(:test_scores) do
        GsdataCaching::GsDataValue.from_array_of_hashes([
          OpenStruct.new({
            data_type: 1,
            grade: '9',
            year: 2015,
            school_value: 10,
            state_value: 50,
            state_cohort_count: 4
          }).freeze,
          OpenStruct.new({
            data_type: 1,
            grade: '10',
            year: 2015,
            school_value: 20,
            state_value: 100,
            school_cohort_count: 8
          }).freeze
        ]).freeze
      end

      it { is_expected.to be_present }
      its(:school_value) { is_expected.to eq(15) }
      its(:state_value) { is_expected.to eq(75) }
      its(:school_cohort_count) { is_expected.to be_nil }
      its(:state_cohort_count) { is_expected.to be_nil }
    end

    context 'when there are zero number of students tested for any test' do
      let(:test_scores) do 
        GsdataCaching::GsDataValue.from_array_of_hashes([
          OpenStruct.new({
            data_type: 1,
            grade: '9',
            year: 2015,
            school_value: 10,
            state_value: 50,
            school_cohort_count: 0,
            state_cohort_count: 0,
          }).freeze,
          OpenStruct.new({
            data_type: 1,
            grade: '10',
            year: 2015,
            school_value: 20,
            state_value: 100,
            school_cohort_count: 0,
            state_cohort_count: 0,
          }).freeze
        ]).freeze
      end

      it { is_expected.to be_present }
      its(:school_value) { is_expected.to eq(15) }
      its(:state_value) { is_expected.to eq(75) }
      its(:school_cohort_count) { is_expected.to be_nil }
      its(:state_cohort_count) { is_expected.to be_nil }
    end

    context 'when there are nil number of students tested for any test' do
      let(:test_scores) do
        GsdataCaching::GsDataValue.from_array_of_hashes([
          OpenStruct.new({
            data_type: 1,
            grade: '9',
            year: 2015,
            school_value: 10,
            state_value: 50
          }).freeze,
          OpenStruct.new({
            data_type: 1,
            grade: '10',
            year: 2015,
            school_value: 20,
            state_value: 100
          }).freeze
        ]).freeze
      end

      it { is_expected.to be_present }
      its(:school_value) { is_expected.to eq(15) }
      its(:state_value) { is_expected.to eq(75) }
      its(:school_cohort_count) { is_expected.to be_nil }
      its(:state_cohort_count) { is_expected.to be_nil }
    end

    context 'with two data sets that already contain grade all' do
      let(:test_scores) do 
        GsdataCaching::GsDataValue.from_array_of_hashes([
          OpenStruct.new({
            data_type: 1,
            grade: 'All',
            year: 2015,
          }).freeze,
          OpenStruct.new({
            data_type: 1,
            grade: '10',
            year: 2015,
          }).freeze
        ]).freeze
      end

      it 'should raise an ArgumentError' do
        expect { subject }.to raise_error(ArgumentError)
      end
    end

    context 'with invalid number_tested values' do
      let(:test_scores) do
        GsdataCaching::GsDataValue.from_array_of_hashes([
            OpenStruct.new({
                               data_type: 1,
                               grade: '9',
                               year: 2015,
                               breakdowns: '0',
                               school_value: 10,
                               state_value: 50,
                               school_cohort_count: false,
                               state_cohort_count: '<2',
                           }).freeze,
            OpenStruct.new({
                               data_type: 1,
                               grade: '10',
                               year: 2015,
                               breakdowns: '0',
                               school_value: 20,
                               state_value: 100,
                               school_cohort_count: -5,
                               state_cohort_count: '0.3',
                           }).freeze
        ]).freeze
      end

      it { is_expected.to be_present }
      its(:school_value) { is_expected.to eq(15) }
      its(:state_value) { is_expected.to eq(75) }
      its(:school_cohort_count) { is_expected.to be_nil }
      its(:state_cohort_count) { is_expected.to be_nil }
      its(:data_type) { is_expected.to eq(1) }
      its(:breakdowns) { is_expected.to eq(['0']) }
    end

    context 'with just value_text values' do
      let(:test_scores) do
        GsdataCaching::GsDataValue.from_array_of_hashes([
            OpenStruct.new({
                               data_type: 1,
                               grade: '9',
                               year: 2015,
                               breakdowns: '0',
                               school_value_text: '<10',
                               state_value: 50,
                               school_cohort_count: 10,
                               state_cohort_count: 10,
                           }).freeze,
            OpenStruct.new({
                               data_type: 1,
                               grade: '10',
                               year: 2015,
                               breakdowns: '0',
                               school_value_text: '<20',
                               state_value: 100,
                               school_cohort_count: 10,
                               state_cohort_count: 10,
                           }).freeze
        ]).freeze
      end

      it { is_expected.to be_present }
      its(:school_value) { is_expected.to eq(nil) }
      its(:state_value) { is_expected.to eq(75) }
      its(:school_cohort_count) { is_expected.to eq(nil) }
      its(:state_cohort_count) { is_expected.to eq(20) }
      its(:data_type) { is_expected.to eq(1) }
      its(:breakdowns) { is_expected.to eq(['0']) }
    end

    context 'with value_float and value_text values' do
      let(:test_scores) do
        GsdataCaching::GsDataValue.from_array_of_hashes([
            OpenStruct.new({
                               data_type: 1,
                               grade: '9',
                               year: 2015,
                               breakdowns: '0',
                               school_value: 10,
                               school_value_text: '<10',
                               state_value: 50,
                               school_cohort_count: 10,
                               state_cohort_count: 10,
                           }).freeze,
            OpenStruct.new({
                               data_type: 1,
                               grade: '10',
                               year: 2015,
                               breakdowns: '0',
                               school_value: 20,
                               school_value_text: '<20',
                               state_value: 100,
                               school_cohort_count: 10,
                               state_cohort_count: 10,
                           }).freeze
        ]).freeze
      end

      it { is_expected.to be_present }
      its(:school_value) { is_expected.to eq(15) }
      its(:state_value) { is_expected.to eq(75) }
      its(:school_cohort_count) { is_expected.to eq(20) }
      its(:state_cohort_count) { is_expected.to eq(20) }
      its(:data_type) { is_expected.to eq(1) }
      its(:breakdowns) { is_expected.to eq(['0']) }
    end

    context 'when test scores contain value_text' do
      let(:test_scores) do
        GsdataCaching::GsDataValue.from_array_of_hashes([
            OpenStruct.new({
                               data_type: 1,
                               grade: '9',
                               year: 2015,
                               breakdowns: '0',
                               school_value: 10,
                               state_value: 50,
                               school_cohort_count: false,
                               state_cohort_count: '<2',
                           }).freeze,
            OpenStruct.new({
                               data_type: 1,
                               grade: '10',
                               year: 2015,
                               breakdowns: '0',
                               school_value: 20,
                               state_value: 100,
                               school_cohort_count: -5,
                               state_cohort_count: '0.3',
                           }).freeze
        ]).freeze
      end

      it { is_expected.to be_present }
      its(:school_value) { is_expected.to eq(15) }
      its(:state_value) { is_expected.to eq(75) }
    end

    context 'with invalid characters after the value_float' do
      let(:test_scores) do
        GsdataCaching::GsDataValue.from_array_of_hashes([
            OpenStruct.new({
                               data_type: 1,
                               grade: '9',
                               year: 2015,
                               breakdowns: '0',
                               school_value: '10.0e0',
                               state_value: '50.0e0',
                               school_cohort_count: 4,
                               state_cohort_count: 2,
                           }).freeze,
            OpenStruct.new({
                               data_type: 1,
                               grade: '10',
                               year: 2015,
                               breakdowns: '0',
                               school_value: '20.000x5fb',
                               state_value: '100.00qrx^5',
                               school_cohort_count: 8,
                               state_cohort_count: 3,
                           }).freeze
        ]).freeze
      end

      its(:to_h) { is_expected.to_not be_present }
    end

    context 'with no data sets' do
      let(:test_scores) do
        GsdataCaching::GsDataValue.from_array_of_hashes([]).freeze
      end

      it 'returns nil' do
        expect(subject.to_h).to be_empty
      end
    end
  end
end
