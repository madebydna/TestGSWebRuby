require 'spec_helper'

describe TestScoresCaching::BreakdownsCacher do
  let(:school) { FactoryGirl.build(:alameda_high_school) }
  let(:test_scores_cacher) { TestScoresCaching::BreakdownsCacher.new(school) }

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
        breakdown_name: 'a breakdown'
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

