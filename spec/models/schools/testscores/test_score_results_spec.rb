require 'spec_helper'

describe TestScoreResults do
  let(:school) { FactoryGirl.build(:school) }

  describe 'fetch_test_scores' do
    before do
      allow(subject).to receive(:sort_test_scores) do |test_scores|
        test_scores
      end
      allow(subject).to receive(:force_inclusion_of_breakdown) do |test_scores|
        test_scores
      end
    end
    
    it 'should not return data, since there are no results from the database.' do
      allow(SchoolCache).to receive(:for_school).with('test_scores',school.id,school.state).and_return({})

      expect(subject.fetch_test_scores(school)).to be_empty
    end

    it 'should not return data, since there are no results from the database.' do
      allow(SchoolCache).to receive(:for_school).with('test_scores',school.id,school.state).and_return(nil)

      expect(subject.fetch_test_scores school).to be_empty
    end

    it 'should return test data' do
      school_cache_value = '{"data_sets_and_values":[{"data_type_id":18,"data_set_id":84122,"level_code":"e,m,h","subject_id":9,"grade":"9","year":2010,"school_value_text":null,"school_value_float":20,"state_value_text":null,"state_value_float":22,"breakdown_id":1,"number_students_tested":269697},{"data_type_id":18,"data_set_id":84302,"level_code":"e,m,h","subject_id":9,"grade":"9","year":2010,"school_value_text":null,"school_value_float":33,"state_value_text":null,"state_value_float":45,"breakdown_id":1,"number_students_tested":134540}],"data_types":{"18":{"test_label":"XYZ test","test_description":"This test is awesome.","test_source":"xyz test source"}}}'
      allow(SchoolCache).to receive(:for_school).with('test_scores',school.id,school.state).and_return(school_cache(school_cache_value))

      expect(subject.fetch_test_scores(school)).to_not be_empty
    end

    it 'should not return data, since there is a JSON parse error' do
      school_cache_value = '$aksd{invalid json]'
      allow(SchoolCache).to receive(:for_school).with('test_scores',school.id,school.state).and_return(school_cache(school_cache_value))

      expect(subject.fetch_test_scores(school)).to be_empty
    end

    def school_cache(school_cache_value)
      FactoryGirl.build(:school_cache, name: 'test_scores', school_id: school.id, state: school.state, value: school_cache_value)
    end
  end

  describe 'sort_test_scores' do

    let(:test_scores_hash) do
      {
        18 => {
          All: {
            test_label: 'a label',
            test_source: 'a source',
            test_description: 'a description',
            grades: {
              3 => {
                label: 'a grade label',
                level_code: {
                  'h' => {
                    'Algebra 2' => {
                      2010 => {
                        number_students_tested: 100,
                        score: '10',
                        state_average: '20'
                      },
                      2011 => {
                        number_students_tested: 100,
                        score: '10',
                        state_average: '20'
                      }
                    },
                    'Algebra 1' => {
                      2010 => {
                        number_students_tested: 100,
                        score: '10',
                        state_average: '20'
                      },
                      2011 => {
                        number_students_tested: 100,
                        score: '10',
                        state_average: '20'
                      }
                    }
                  }
                }
              },
              2 => {
                label: 'a grade label',
                level_code: {
                  'h' => {
                    'Algebra 2' => {
                      2010 => {
                        number_students_tested: 100,
                        score: '10',
                        state_average: '20'
                      },
                      2011 => {
                        number_students_tested: 100,
                        score: '10',
                        state_average: '20'
                      }
                    },
                    'Algebra 1' => {
                      2010 => {
                        number_students_tested: 100,
                        score: '10',
                        state_average: '20'
                      },
                      2011 => {
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
        },
        19 => {
          All: {
            test_label: 'a label',
            test_source: 'a source',
            test_description: 'a description',
            grades: {
              2 => {
                label: 'a grade label',
                level_code: {
                  'h' => {
                    'Algebra 2' => {
                      2010 => {
                        number_students_tested: 100,
                        score: '10',
                        state_average: '20'
                      },
                      2011 => {
                        number_students_tested: 100,
                        score: '10',
                        state_average: '20'
                      }
                    },
                    'Algebra 1' => {
                      2010 => {
                        number_students_tested: 100,
                        score: '10',
                        state_average: '20'
                      },
                      2011 => {
                        number_students_tested: 100,
                        score: '10',
                        state_average: '20'
                      }
                    }
                  }
                }
              },
              1 => {
                label: 'a grade label',
                level_code: {
                  'h' => {
                    'algebra 2' => {
                      2010 => {
                        number_students_tested: 100,
                        score: '10',
                        state_average: '20'
                      },
                      2011 => {
                        number_students_tested: 100,
                        score: '10',
                        state_average: '20'
                      }
                    },
                    'algebra 1' => {
                      2010 => {
                        number_students_tested: 100,
                        score: '10',
                        state_average: '20'
                      },
                      2011 => {
                        number_students_tested: 100,
                        score: '10',
                        state_average: '20'
                      }
                    }
                  }
                }
              }
            },
            lowest_grade: 1
          }
        }
      }
    end

    it 'should maintain original number of data types' do
      sorted_test_scores = subject.sort_test_scores(test_scores_hash)
      expect(sorted_test_scores.size).to eq(2)
    end

    it 'should sort test data types by lowest grade, descending' do
      sorted_test_scores = subject.sort_test_scores(test_scores_hash)
      #test should be sorted by the lowest grade. Hence test data type id 19 should be first.
      expect(sorted_test_scores.keys[0]).to eq(19)
      expect(sorted_test_scores.keys[1]).to eq(18)
    end

    it 'should sort grades in ascending order' do
      #grades should be sorted in ascending order.
      sorted_test_scores = subject.sort_test_scores(test_scores_hash)
      expect(sorted_test_scores.values[0][:All][:grades].keys[0]).to eq(1)
      expect(sorted_test_scores.values[0][:All][:grades].keys[1]).to eq(2)
    end

    it 'should sort subjects in ascending order' do
      sorted_test_scores = subject.sort_test_scores(test_scores_hash)
      #subjects should be sorted in alphabetical order.
      expect(sorted_test_scores.values[0].seek(:All, :grades, 1, :level_code, 'h').keys[0]).to eq('algebra 1')
      expect(sorted_test_scores.values[0].seek(:All, :grades, 1, :level_code, 'h').keys[1]).to eq('algebra 2')
    end

    it 'should sort years in descending order' do
      sorted_test_scores = subject.sort_test_scores(test_scores_hash)
      #years are sorted in descending order.
      expect(sorted_test_scores.values[0].seek(:All, :grades, 1, :level_code, 'h', 'algebra 1').keys[0]).to eq(2011)
      expect(sorted_test_scores.values[0].seek(:All, :grades, 1, :level_code, 'h', 'algebra 1').keys[1]).to eq(2010)
    end
  end

end
