require 'spec_helper'

describe TestScoresCaching::TestScoresCacher do
  let(:school) { FactoryGirl.build(:alameda_high_school) }
  let(:test_scores_cacher) { TestScoresCaching::TestScoresCacher.new(school) }

  describe '#build_hash_for_cache' do

    context 'with differing data types' do
      let(:query_results) do
        [
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
          }),
          Hashie::Mash.new({
            data_type_id: 2,
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
          })
        ]
      end
      let(:expected) do
        {
          1 => {
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
            },
            lowest_grade: 2
          },
          2 => {
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
            },
            lowest_grade: 2
          }
        }
      end

      it 'should build hash with both data types' do
        allow(test_scores_cacher).to receive(:query_results)
          .and_return(query_results)
        expect(test_scores_cacher.build_hash_for_cache).to eq(expected)
      end
    end

    context 'with differing grades' do
      let(:query_results) do
        [
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
          }),
          Hashie::Mash.new({
            data_type_id: 1,
            test_label: 'a label',
            test_source: 'a source',
            test_description: 'a description',
            grade_label: 'a grade label',
            level_code: 'h',
            subject: 'Math',
            grade: Grade.from_string('3'),
            year: 2010,
            school_value: '10',
            state_value: '20',
            number_students_tested: 100,
          })
        ]
      end
      let(:expected) do
        {
          1 => {
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
              },
              3 => {
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
            },
            lowest_grade: 2
          }
        }
      end

      it 'should build hash with both data types' do
        allow(test_scores_cacher).to receive(:query_results)
          .and_return(query_results)
        expect(test_scores_cacher.build_hash_for_cache).to eq(expected)
      end
    end

    context 'with differing years' do
      let(:query_results) do
        [
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
          }),
          Hashie::Mash.new({
            data_type_id: 1,
            test_label: 'a label',
            test_source: 'a source',
            test_description: 'a description',
            grade_label: 'a grade label',
            level_code: 'h',
            subject: 'Math',
            grade: Grade.from_string('2'),
            year: 2011,
            school_value: '20',
            state_value: '40',
            number_students_tested: 110,
          })
        ]
      end
      let(:expected) do
        {
          1 => {
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
                      },
                      2011 => {
                        number_students_tested: 110,
                        score: '20',
                        state_average: '40'
                      }
                    }
                  }
                }
              }
            },
            lowest_grade: 2
          }
        }
      end

      it 'should build hash with both data types' do
        allow(test_scores_cacher).to receive(:query_results)
          .and_return(query_results)
        expect(test_scores_cacher.build_hash_for_cache).to eq(expected)
      end
    end
    
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
      })
    }

    it 'builds the correct hash' do
      expected = {
        1 => {
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

      expect(test_scores_cacher.build_hash_for_data_set(result))
        .to eq(expected)
    end

    it 'when there is proficiency band, inner hash key names reflect this' do
      result['proficiency_band_name'] = 'advanced'
      expected = {
        1 => {
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
                      advanced_number_students_tested: 100,
                      advanced_score: '10',
                      advanced_state_average: '20'
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

end

