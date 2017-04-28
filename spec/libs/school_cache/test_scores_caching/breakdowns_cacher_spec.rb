require 'spec_helper'

describe TestScoresCaching::BreakdownsCacher do
  let(:school) { FactoryGirl.build(:alameda_high_school) }
  let(:test_scores_cacher) { TestScoresCaching::BreakdownsCacher.new(school) }

  describe '#query_results' do
    let(:test_data_types) {{17 => true, 19 => true, 21 => true}}

    it 'should call feed-specific methods on TestDataSet' do
      allow(TestDataSet).to receive(:fetch_test_scores).and_return []
      allow(TestDataSet).to receive(:fetch_test_scores).and_return []
      expect(TestDataSet).not_to receive(:fetch_feed_test_scores)
      expect(test_scores_cacher.query_results).to be_empty
    end

    it 'should keep only known data type ids' do
      allow(test_scores_cacher).to receive(:test_data_types).and_return(test_data_types)
      expect(TestDataSet).to receive(:fetch_test_scores).and_return [
        Struct.new(:data_type_id, :subject_id, :year, :grade, :breakdown_id).new(17, nil, nil, 'All', nil),
        Struct.new(:data_type_id, :subject_id, :year, :grade, :breakdown_id).new(18, nil, nil, 'All', nil),
        Struct.new(:data_type_id, :subject_id, :year, :grade, :breakdown_id).new(19, nil, nil, 'All', nil)
      ]
      expect(test_scores_cacher.query_results).not_to be_empty
      expect(test_scores_cacher.query_results.map {|q| q.data_type_id}.sort).to eq([17,19])
    end
  end

  describe '.active' do
    it {expect(TestScoresCaching::BreakdownsCacher.active?).to be_truthy }
  end

  describe '#build_hash_for_data_set' do

    let(:result) {
      Hashie::Mash.new({
        data_type_id: 1,
        test_label: 'a label',
        test_source: 'a source',
        test_description: 'a description',
        grade_label: 'a grade label',
        level_code: 'h',
        subject: 'Math',
        grade: Grade.from_string('2'),
        year: 2010,
        school_value: '10',
        state_value: '20',
        number_students_tested: 100,
        test_scores_breakdown_name: 'a breakdown'
      })
    }

    it 'builds the correct hash' do
      expected = {
        1 => {
          'a breakdown' => {
            test_label: 'a label',
            test_source: 'a source',
            test_description: 'a description',
            grades: {
              2 => {
                label: 'a grade label',
                level_code: {
                  'h' => {
                    'Math' => {
                      2010 => {
                        number_students_tested: 100,
                        state_number_tested: nil,
                        score: '10',
                        state_average: '20'
                      }
                    }
                  }
                }
              }
            }
          }
        }
      }

      expect(test_scores_cacher.build_hash_for_data_set(result))
        .to eq(expected)
    end
  end

  describe '#add_lowest_grade_to_hash' do
    let(:hash) do
      {
        1 => {
          'a breakdown' => {
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
      }
    end

    it 'should add lowest grade to each data type hash' do
      expected = {
        1 => {
          'a breakdown' => {
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
      }
      expect(test_scores_cacher.add_lowest_grade_to_hash(hash))
        .to eq(expected)
    end

  end

end

