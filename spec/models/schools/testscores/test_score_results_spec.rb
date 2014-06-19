require 'spec_helper'

describe TestScoreResults do
  let(:school) { FactoryGirl.build(:school) }

  describe 'fetch_test_scores' do
    it 'should not return data, since there are no results from the database.' do
      allow(SchoolCache).to receive(:for_school).with('test_scores',school.id,school.state).and_return({})

      expect(subject.fetch_test_scores(school)).to be_empty
    end

    it 'should not return data, since there are no results from the database.' do
      allow(SchoolCache).to receive(:for_school).with('test_scores',school.id,school.state).and_return(nil)

      expect(subject.fetch_test_scores school).to be_empty
    end

    it 'should return test data' do
      school_cache_value = '{"data_sets_and_values":[{"data_type_id":18,"data_set_id":84122,"level_code":"e,m,h","subject_id":9,"grade":"9","year":2010,"school_value_text":null,"school_value_float":20,"state_value_text":null,"state_value_float":22,"breakdown_id":1,"school_number_tested":269697},{"data_type_id":18,"data_set_id":84302,"level_code":"e,m,h","subject_id":9,"grade":"9","year":2010,"school_value_text":null,"school_value_float":33,"state_value_text":null,"state_value_float":45,"breakdown_id":1,"school_number_tested":134540}],"data_types":{"18":{"test_label":"XYZ test","test_description":"This test is awesome.","test_source":"xyz test source"}}}'
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

  describe 'build_test_scores_hash' do
    it 'should return empty test scores hash, since there are no test data sets.' do
      expect(subject.build_test_scores_hash({},school)).to be_empty
    end

    it 'should return empty test scores hash, since there are no test data sets.' do
      expect(subject.build_test_scores_hash(nil, school)).to be_empty
    end

    it 'should return test scores hash for all the data type ids' do
      data_sets_and_values = {
        'data_sets_and_values' => [
          {
            'data_type_id' => 18,
            'data_set_id' => 84122,
            'level_code' => 'e,m,h',
            'subject_id' => 7,
            'grade' => '9',
            'year' => 2010,
            'school_value_text' => nil,
            'school_value_float' => 20,
            'state_value_text' => nil,
            'state_value_float' => 22,
            'breakdown_id' => 1,
            'school_number_tested' => 269697
          },
          {
            'data_type_id' => 18,
            'data_set_id' => 84302,
            'level_code' => 'e,m,h',
            'subject_id' => 9,
            'grade' => '8',
            'year' => 2010,
            'school_value_text' => nil,
            'school_value_float' => 33,
            'state_value_text' => nil,
            'state_value_float' => 45,
            'breakdown_id' => 1,
            'school_number_tested' => 134540
          },
          {
            'data_type_id' => 19,
            'data_set_id' => 84488,
            'level_code' => 'e,m,h',
            'subject_id' => 11,
            'grade' => '5',
            'year' => 2010,
            'school_value_text' => nil,
            'school_value_float' => 80,
            'state_value_text' => nil,
            'state_value_float' => 69,
            'breakdown_id' => 1,
            'school_number_tested' => 134540
          }
        ],
        'data_types' => {
          '18' => {
            'test_label' => 'XYZ test',
            'test_description' => 'This describes the test.',
            'test_source' => 'This is the source of test data'
          }
        }
      }
      test_scores_hash = subject.build_test_scores_hash(data_sets_and_values,school)

      expect(test_scores_hash.size).to eq(2)
      expect(test_scores_hash[18][:grades].size).to eq(2)
      expect(test_scores_hash[19][:grades].size).to eq(1)
      expect(test_scores_hash[18][:lowest_grade]).to eq(8)
      expect(test_scores_hash[19][:lowest_grade]).to eq(5)
      expect(test_scores_hash[18][:test_description]).to eq('This describes the test.')
      expect(test_scores_hash[18][:test_source]).to eq('This is the source of test data')
      expect(test_scores_hash[18][:test_label]).to eq('XYZ test')
    end

    it 'should return test scores hash for all the data type ids but with no description,source and label' do
      data_sets_and_values = {
        'data_sets_and_values' => [
          {
            'data_type_id' => 18,
            'data_set_id' => 84122,
            'level_code' => 'e,m,h',
            'subject_id' => 7,
            'grade' => '9',
            'year' => 2010,
            'school_value_text' => nil,
            'school_value_float' => 20,
            'state_value_text' => nil,
            'state_value_float' => 22,
            'breakdown_id' => 1,
            'school_number_tested' => 269697
          },
          {
            'data_type_id' => 18,
            'data_set_id' => 84302,
            'level_code' => 'e,m,h',
            'subject_id' => 9,
            'grade' => '8',
            'year' => 2010,
            'school_value_text' => nil,
            'school_value_float' => 33,
            'state_value_text' => nil,
            'state_value_float' => 45,
            'breakdown_id' => 1,
            'school_number_tested' => 134540
          },
          {
            'data_type_id' => 19,
            'data_set_id' => 84488,
            'level_code' => 'e,m,h',
            'subject_id' => 11,
            'grade' => '5',
            'year' => 2010,
            'school_value_text' => nil,
            'school_value_float' => 80,
            'state_value_text' => nil,
            'state_value_float' => 69,
            'breakdown_id' => 1,
            'school_number_tested' => 134540
          }
        ]
      }

      test_scores_hash = subject.build_test_scores_hash(data_sets_and_values,school)

      expect(test_scores_hash.size).to eq(2)
      expect(test_scores_hash[18][:grades].size).to eq(2)
      expect(test_scores_hash[19][:grades].size).to eq(1)
      expect(test_scores_hash[18][:lowest_grade]).to eq(8)
      expect(test_scores_hash[19][:lowest_grade]).to eq(5)
      expect(test_scores_hash[18][:test_description]).to be_blank
      expect(test_scores_hash[18][:test_source]).to be_blank
      expect(test_scores_hash[18][:test_label]).to be_blank
    end

    it 'should get the right grades from the level code, since grade=all' do
      school.level_code = 'e,m'

      data_sets_and_values = {
        'data_sets_and_values' => [
          {
            'data_type_id' => 18,
            'data_set_id' => 84122,
            'level_code' => 'e',
            'subject_id' => 7,
            'grade' => 'All',
            'year' => 2010,
            'school_value_text' => nil,
            'school_value_float' => 20,
            'state_value_text' => nil,
            'state_value_float' => 22,
            'breakdown_id' => 1,
            'school_number_tested' => 269697
          },
          {
            'data_type_id' => 18,
            'data_set_id' => 84302,
            'level_code' => 'm,h',
            'subject_id' => 9,
            'grade' => 'All',
            'year' => 2010,
            'school_value_text' => nil,
            'school_value_float' => 33,
            'state_value_text' => nil,
            'state_value_float' => 45,
            'breakdown_id' => 1,
            'school_number_tested' => 134540
          },
          {
            'data_type_id' => 19,
            'data_set_id' => 84488,
            'level_code' => 'e,m,h',
            'subject_id' => 11,
            'grade' => 'All',
            'year' => 2010,
            'school_value_text' => nil,
            'school_value_float' => 80,
            'state_value_text' => nil,
            'state_value_float' => 69,
            'breakdown_id' => 1,
            'school_number_tested' => 24737
          }
        ]
      }

      test_scores_hash = subject.build_test_scores_hash(data_sets_and_values,school)

      expect(test_scores_hash.size).to eq(2)
      expect(test_scores_hash[18][:lowest_grade]).to eq(15)
      expect(test_scores_hash[18][:grades].size).to eq(2)
      expect(test_scores_hash[18][:grades].keys[0].value).to eq(15)
      expect(test_scores_hash[18][:grades].keys[1].value).to eq(16)
      #school does not have level 'h' hence show only 'e,m'
      expect(test_scores_hash[18][:grades].values[0][:label]).to eq('Elementary school')
      expect(test_scores_hash[18][:grades].values[1][:label]).to eq('Middle school')
      expect(test_scores_hash[19][:lowest_grade]).to eq(16)
      expect(test_scores_hash[19][:grades].size).to eq(1)
      expect(test_scores_hash[19][:grades].keys[0].value).to eq(16)
      #school does not have level 'h' hence show only 'e,m'
      expect(test_scores_hash[19][:grades].values[0][:label]).to eq('Elementary and Middle school')
    end

    it 'should return rounded test scores.' do
      data_sets_and_values = {
        'data_sets_and_values' => [
          {
            'data_type_id' => 18,
            'data_set_id' => 84122,
            'level_code' => 'e,m,h',
            'subject_id' => 7,
            'grade' => '9',
            'year' => 2010,
            'school_value_text' => nil,
            'school_value_float' => 20.499,
            'state_value_text' => nil,
            'state_value_float' => 22,
            'breakdown_id' => 1,
            'school_number_tested' => 269697
          },
          {
            'data_type_id' => 19,
            'data_set_id' => 84488,
            'level_code' => 'e,m,h',
            'subject_id' => 11,
            'grade' => '5',
            'year' => 2010,
            'school_value_text' => nil,
            'school_value_float' => 80.5,
            'state_value_text' => nil,
            'state_value_float' => 69,
            'breakdown_id' => 1,
            'school_number_tested' => 24737
          }
        ]
      }


      test_scores_hash = subject.build_test_scores_hash(data_sets_and_values,school)

      expect(test_scores_hash.values.first.seek(:grades, Grade.from_string('9'), :level_code, LevelCode.new('e,m,h'),
                                             'algebra 1', 2010, 'score')).to eq(20)

      expect(test_scores_hash.values[1].seek(:grades, Grade.from_string('5'), :level_code, LevelCode.new('e,m,h'),
                                             'algebra 2', 2010, 'score')).to eq(81)
    end

    it 'should not try to round test scores if its nil or a string value.' do
      data_sets_and_values = {
        'data_sets_and_values' => [
          {
            'data_type_id' => 18,
            'data_set_id' => 84122,
            'level_code' => 'e,m,h',
            'subject_id' => 7,
            'grade' => '9',
            'year' => 2010,
            'school_value_text' => nil,
            'school_value_float' => nil,
            'state_value_text' => nil,
            'state_value_float' => nil,
            'breakdown_id' => 1,
            'school_number_tested' => 269697
          },
          {
            'data_type_id' => 19,
            'data_set_id' => 84488,
            'level_code' => 'e,m,h',
            'subject_id' => 11,
            'grade' => '5',
            'year' => 2010,
            'school_value_text' => 'string value',
            'school_value_float' => nil,
            'state_value_text' => 'string value',
            'state_value_float' => nil,
            'breakdown_id' => 1,
            'school_number_tested' => 24737
          }
        ]
      }

      test_scores_hash = subject.build_test_scores_hash(data_sets_and_values,school)

      expect(test_scores_hash.values.first.seek(:grades, Grade.from_string('9'), :level_code, LevelCode.new('e,m,h'),
                                                'algebra 1', 2010, 'score')).to be_blank

      expect(test_scores_hash.values.first.seek(:grades, Grade.from_string('9'), :level_code, LevelCode.new('e,m,h'),
                                                'algebra 1', 2010, 'state_avg')).to be_blank

      expect(test_scores_hash.values[1].seek(:grades, Grade.from_string('5'), :level_code, LevelCode.new('e,m,h'),
                                             'algebra 2', 2010, 'score')).to eq('string value')

    end

    it 'should set the number of students tested' do
      data_sets_and_values = {
        'data_sets_and_values' =>[
          {
            'data_type_id' => 18,
            'data_set_id' => 84122,
            'level_code' => 'e,m,h',
            'subject_id' => 7,
            'grade' => '9',
            'year' => 2010,
            'school_value_text' => nil,
            'school_value_float' => 20.499,
            'state_value_text' => nil,
            'state_value_float' => 22,
            'breakdown_id' => 1,
            'school_number_tested' => 300
          }
        ]
      }

      test_scores_hash = subject.build_test_scores_hash(data_sets_and_values,school)

      expect(test_scores_hash.values[0].seek(:grades, Grade.from_string('9'), :level_code, LevelCode.new('e,m,h'),
                                             'algebra 1', 2010, 'school_number_tested')).to eq(300)

    end

  end

  describe 'sort_test_scores' do
    it 'should sort test scores' do
      data_sets_and_values = {
        'data_sets_and_values' => [
          {
            'data_type_id' => 18,
            'data_set_id' => 84122,
            'level_code' => 'e,m,h',
            'subject_id' => 7,
            'grade' => '9',
            'year' => 2010,
            'school_value_text' => nil,
            'school_value_float' => 20,
            'state_value_text' => nil,
            'state_value_float' => 22,
            'breakdown_id' => 1,
            'school_number_tested' => 269697
          },
          {
            'data_type_id' => 19,
            'data_set_id' => 84488,
            'level_code' => 'e,m,h',
            'subject_id' => 11,
            'grade' => '7',
            'year' => 2010,
            'school_value_text' => 'text value',
            'school_value_float' => 90,
            'state_value_text' => nil,
            'state_value_float' => 77,
            'breakdown_id' => 1,
            'school_number_tested' => 24737
          },
          {
            'data_type_id' => 18,
            'data_set_id' => 84302,
            'level_code' => 'e,m,h',
            'subject_id' => 7,
            'grade' => '9',
            'year' => 2009,
            'school_value_text' => nil,
            'school_value_float' => 33,
            'state_value_text' => nil,
            'state_value_float' => 45,
            'breakdown_id' => 1,
            'school_number_tested' => 134540
          },
          {
            'data_type_id' => 18,
            'data_set_id' => 84302,
            'level_code' => 'e,m,h',
            'subject_id' => 9,
            'grade' => '8',
            'year' => 2010,
            'school_value_text' => nil,
            'school_value_float' => 31,
            'state_value_text' => nil,
            'state_value_float' => 35,
            'breakdown_id' => 1,
            'school_number_tested' => 134540
          },
          {
            'data_type_id' => 18,
            'data_set_id' => 84302,
            'level_code' => 'e,m,h',
            'subject_id' => 19,
            'grade' => '9',
            'year' => 2009,
            'school_value_text' => nil,
            'school_value_float' => 36,
            'state_value_text' => nil,
            'state_value_float' => 55,
            'breakdown_id' => 1,
            'school_number_tested' => 134540
          },
          {
            'data_type_id' => 18,
            'data_set_id' => 84302,
            'level_code' => 'e,m,h',
            'subject_id' => 19,
            'grade' => '10',
            'year' => 2009,
            'school_value_text' => nil,
            'school_value_float' => 38,
            'state_value_text' => nil,
            'state_value_float' => 56,
            'breakdown_id' => 1,
            'school_number_tested' => 134540
          },
          {
            'data_type_id' => 18,
            'data_set_id' => 84482,
            'level_code' => 'e,m,h',
            'subject_id' => 11,
            'grade' => '9',
            'year' => 2009,
            'school_value_text' => nil,
            'school_value_float' => 80,
            'state_value_text' => 69,
            'state_value_float' => 56,
            'breakdown_id' => 1,
            'school_number_tested' => 134540
          },
          {
            'data_type_id' => 19,
            'data_set_id' => 84488,
            'level_code' => 'e,m,h',
            'subject_id' => 11,
            'grade' => '7',
            'year' => 2009,
            'school_value_text' => nil,
            'school_value_float' => 70,
            'state_value_text' => nil,
            'state_value_float' => 68,
            'breakdown_id' => 1,
            'school_number_tested' => 24737
          }
        ]
      }
      test_scores_hash = subject.build_test_scores_hash(data_sets_and_values,school)

      sorted_test_scores = subject.sort_test_scores(test_scores_hash)

      expect(sorted_test_scores.size).to eq(2)

      #test should be sorted by the lowest grade. Hence test data type id 19 should be first.
      expect(sorted_test_scores.keys[0]).to eq(19)
      expect(sorted_test_scores.keys[1]).to eq(18)

      #grades should be sorted in ascending order.
      expect(sorted_test_scores.values[1][:grades].keys[0].value).to eq (8)
      expect(sorted_test_scores.values[1][:grades].keys[1].value).to eq (9)
      expect(sorted_test_scores.values[1][:grades].keys[2].value).to eq (10)

      #subjects should be sorted in alphabetical order.
      expect(sorted_test_scores.values[1].seek(:grades, Grade.from_string('9'), :level_code, LevelCode.new('e,m,h')).keys[0]).to eq('algebra 1')
      expect(sorted_test_scores.values[1].seek(:grades, Grade.from_string('9'), :level_code, LevelCode.new('e,m,h')).keys[1]).to eq('algebra 2')
      expect(sorted_test_scores.values[1].seek(:grades, Grade.from_string('9'), :level_code, LevelCode.new('e,m,h')).keys[2]).to eq('english')

      expect(sorted_test_scores.values[1][:grades].values[1][:level_code].values[0].keys[0]).to eq ('algebra 1')
      expect(sorted_test_scores.values[1][:grades].values[1][:level_code].values[0].keys[1]).to eq ('algebra 2')
      expect(sorted_test_scores.values[1][:grades].values[1][:level_code].values[0].keys[2]).to eq ('english')

      #years are sorted in descending order.
      expect(sorted_test_scores.values[1].seek(:grades, Grade.from_string('9'), :level_code, LevelCode.new('e,m,h'),'algebra 1').keys[0]).to eq(2010)
      expect(sorted_test_scores.values[1].seek(:grades, Grade.from_string('9'), :level_code, LevelCode.new('e,m,h'),'algebra 1').keys[1]).to eq(2009)

    end
  end

end
