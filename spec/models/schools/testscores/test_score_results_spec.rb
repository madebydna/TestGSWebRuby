require 'spec_helper'

describe TestScoreResults do
  let(:school) { FactoryGirl.build(:school) }

  describe 'fetch_test_data_sets_and_values' do
    it 'should not return data, since there are no results from the database.' do
      allow(TestDataSet).to receive(:fetch_test_scores).with(school).and_return([])

      expect(subject.fetch_test_data_sets_and_values school).to be_empty
    end

    it 'should not return data, since there are no results from the database.' do
      allow(TestDataSet).to receive(:fetch_test_scores).with(school).and_return(nil)

      expect(subject.fetch_test_data_sets_and_values school).to be_empty
    end

    it 'should not return data because there are no corresponding entries in TestDataSetFile' do
      test_data_sets_and_values = JSON.parse('[{"active":null,"breakdown_id":1,"data_set_id":null,"data_type_id":18,"ds_id":84122,"grade":"9","id":null,"level_code":"e,m,h","number_tested":269697,"school_id":1103,"school_val_float":20,"school_val_text":null,"state_val_float":22,"state_val_text":null,"subject_id":7,"value_float":null,"value_text":null,"year":2010},{"active":null,"breakdown_id":1,"data_set_id":null,"data_type_id":18,"ds_id":84302,"grade":"9","id":null,"level_code":"e,m,h","number_tested":134540,"school_id":1103,"school_val_float":33,"school_val_text":null,"state_val_float":45,"state_val_text":null,"subject_id":9,"value_float":null,"value_text":null,"year":2010},{"active":null,"breakdown_id":1,"data_set_id":null,"data_type_id":18,"ds_id":84482,"grade":"9","id":null,"level_code":"e,m,h","number_tested":24737,"school_id":1103,"school_val_float":80,"school_val_text":null,"state_val_float":69,"state_val_text":null,"subject_id":11,"value_float":null,"value_text":null,"year":2010}]')
      allow(TestDataSet).to receive(:fetch_test_scores).with(school).and_return(test_data_sets_and_values)

      #none of the test_data_sets_and_values have valid entries in test_data_set_file.
      allow(TestDataSetFile).to receive(:get_valid_data_set_ids).with([84122, 84302, 84482], school).and_return([])

      expect(subject.fetch_test_data_sets_and_values school).to be_empty
    end

    it 'should not return data because there are no corresponding entries in TestDataSetFile' do
      test_data_sets_and_values = JSON.parse('[{"active":null,"breakdown_id":1,"data_set_id":null,"data_type_id":18,"ds_id":84122,"grade":"9","id":null,"level_code":"e,m,h","number_tested":269697,"school_id":1103,"school_val_float":20,"school_val_text":null,"state_val_float":22,"state_val_text":null,"subject_id":7,"value_float":null,"value_text":null,"year":2010},{"active":null,"breakdown_id":1,"data_set_id":null,"data_type_id":18,"ds_id":84302,"grade":"9","id":null,"level_code":"e,m,h","number_tested":134540,"school_id":1103,"school_val_float":33,"school_val_text":null,"state_val_float":45,"state_val_text":null,"subject_id":9,"value_float":null,"value_text":null,"year":2010},{"active":null,"breakdown_id":1,"data_set_id":null,"data_type_id":18,"ds_id":84482,"grade":"9","id":null,"level_code":"e,m,h","number_tested":24737,"school_id":1103,"school_val_float":80,"school_val_text":null,"state_val_float":69,"state_val_text":null,"subject_id":11,"value_float":null,"value_text":null,"year":2010}]')

      allow(TestDataSet).to receive(:fetch_test_scores).with(school).and_return(test_data_sets_and_values)

      #none of the test_data_sets_and_values have valid entries in test_data_set_file.
      allow(TestDataSetFile).to receive(:get_valid_data_set_ids).with([84122, 84302, 84482], school).and_return(nil)

      expect(subject.fetch_test_data_sets_and_values school).to be_empty
    end

    it 'should return test data' do
      test_data_sets_and_values = JSON.parse('[{"active":null,"breakdown_id":1,"data_set_id":null,"data_type_id":18,"ds_id":84122,"grade":"9","id":null,"level_code":"e,m,h","number_tested":269697,"school_id":1103,"school_val_float":20,"school_val_text":null,"state_val_float":22,"state_val_text":null,"subject_id":7,"value_float":null,"value_text":null,"year":2010},{"active":null,"breakdown_id":1,"data_set_id":null,"data_type_id":18,"ds_id":84302,"grade":"9","id":null,"level_code":"e,m,h","number_tested":134540,"school_id":1103,"school_val_float":33,"school_val_text":null,"state_val_float":45,"state_val_text":null,"subject_id":9,"value_float":null,"value_text":null,"year":2010},{"active":null,"breakdown_id":1,"data_set_id":null,"data_type_id":18,"ds_id":84482,"grade":"9","id":null,"level_code":"e,m,h","number_tested":24737,"school_id":1103,"school_val_float":80,"school_val_text":null,"state_val_float":69,"state_val_text":null,"subject_id":11,"value_float":null,"value_text":null,"year":2010}]')

      allow(TestDataSet).to receive(:fetch_test_scores).with(school).and_return(test_data_sets_and_values)

      allow(TestDataSetFile).to receive(:get_valid_data_set_ids).with([84122, 84302, 84482], school).and_return([84122, 84302])

      expect(subject.fetch_test_data_sets_and_values school).to_not be_empty
    end

    it 'should return 2 results' do
      test_data_sets_and_values = JSON.parse('[{"active":null,"breakdown_id":1,"data_set_id":null,"data_type_id":18,"ds_id":84122,"grade":"9","id":null,"level_code":"e,m,h","number_tested":269697,"school_id":1103,"school_val_float":20,"school_val_text":null,"state_val_float":22,"state_val_text":null,"subject_id":7,"value_float":null,"value_text":null,"year":2010},{"active":null,"breakdown_id":1,"data_set_id":null,"data_type_id":18,"ds_id":84302,"grade":"9","id":null,"level_code":"e,m,h","number_tested":134540,"school_id":1103,"school_val_float":33,"school_val_text":null,"state_val_float":45,"state_val_text":null,"subject_id":9,"value_float":null,"value_text":null,"year":2010},{"active":null,"breakdown_id":1,"data_set_id":null,"data_type_id":18,"ds_id":84482,"grade":"9","id":null,"level_code":"e,m,h","number_tested":24737,"school_id":1103,"school_val_float":80,"school_val_text":null,"state_val_float":69,"state_val_text":null,"subject_id":11,"value_float":null,"value_text":null,"year":2010}]')

      allow(TestDataSet).to receive(:fetch_test_scores).with(school).and_return(test_data_sets_and_values)

      #Only 2 of the test_data_sets_and_values have valid entries in test_data_set_file.
      allow(TestDataSetFile).to receive(:get_valid_data_set_ids).with([84122, 84302, 84482], school).and_return([84122, 84302])

      results = subject.fetch_test_data_sets_and_values school

      expect(results.size).to eq(2)
    end
  end

  describe 'build_test_scores_hash' do
    it 'should return empty test scores hash, since there are no test data sets.' do
      test_scores_hash = subject.build_test_scores_hash([],school)

      expect(test_scores_hash).to be_empty
    end

    it 'should return empty test scores hash, since there are no test data sets.' do
      test_scores_hash = subject.build_test_scores_hash(nil, school)

      expect(test_scores_hash).to be_empty
    end

    it 'should return test scores hash for all the data type ids' do
      test_data_sets_and_values = JSON.parse('[{"active":null,"breakdown_id":1,"data_set_id":null,"data_type_id":18,"ds_id":84122,"grade":"9","id":null,"level_code":"e,m,h","number_tested":269697,"school_id":1103,"school_val_float":20,"school_val_text":null,"state_val_float":22,"state_val_text":null,"subject_id":7,"value_float":null,"value_text":null,"year":2010},{"active":null,"breakdown_id":1,"data_set_id":null,"data_type_id":18,"ds_id":84302,"grade":"8","id":null,"level_code":"e,m,h","number_tested":134540,"school_id":1103,"school_val_float":33,"school_val_text":null,"state_val_float":45,"state_val_text":null,"subject_id":9,"value_float":null,"value_text":null,"year":2010},{"active":null,"breakdown_id":1,"data_set_id":null,"data_type_id":18,"ds_id":84482,"grade":"9","id":null,"level_code":"e,m,h","number_tested":24737,"school_id":1103,"school_val_float":80,"school_val_text":null,"state_val_float":69,"state_val_text":null,"subject_id":11,"value_float":null,"value_text":null,"year":2010},{"active":null,"breakdown_id":1,"data_set_id":null,"data_type_id":19,"ds_id":84488,"grade":"5","id":null,"level_code":"e,m,h","number_tested":24737,"school_id":1103,"school_val_float":80,"school_val_text":null,"state_val_float":69,"state_val_text":null,"subject_id":11,"value_float":null,"value_text":null,"year":2010}]')

      test_data_types = {}
      test_descriptions = {}

      #all the data_type_ids in the test_data_sets_and_values have rows in TestDataType table.
      [18,19].each do |data_type_id|
        test_data_types[data_type_id] = Array(FactoryGirl.build(:test_data_type, id: data_type_id))
        test_descriptions[data_type_id] = Array(FactoryGirl.build(:test_description, data_type_id: data_type_id))
      end
      allow(TestDataType).to receive(:by_ids).with([18,19]).and_return(test_data_types)
      allow(TestDescription).to receive(:by_data_type_ids).with([18,19],school.state).and_return(test_descriptions)

      test_scores_hash = subject.build_test_scores_hash(test_data_sets_and_values,school)

      expect(test_scores_hash.size).to eq(2)
      expect(test_scores_hash[18][:grades].size).to eq(2)
      expect(test_scores_hash[19][:grades].size).to eq(1)
      expect(test_scores_hash[18][:lowest_grade]).to eq(8)
      expect(test_scores_hash[19][:lowest_grade]).to eq(5)
      expect(test_scores_hash[18][:test_description]).to eq("This describes the test")
      expect(test_scores_hash[18][:test_source]).to eq("This is the source of test data")
      expect(test_scores_hash[18][:test_label]).to eq("Awesome Test")
    end

    it 'should return test scores hash for only 1 data type id' do
      test_data_sets_and_values = JSON.parse('[{"active":null,"breakdown_id":1,"data_set_id":null,"data_type_id":18,"ds_id":84122,"grade":"9","id":null,"level_code":"e,m,h","number_tested":269697,"school_id":1103,"school_val_float":20,"school_val_text":null,"state_val_float":22,"state_val_text":null,"subject_id":7,"value_float":null,"value_text":null,"year":2010},{"active":null,"breakdown_id":1,"data_set_id":null,"data_type_id":18,"ds_id":84302,"grade":"8","id":null,"level_code":"e,m,h","number_tested":134540,"school_id":1103,"school_val_float":33,"school_val_text":null,"state_val_float":45,"state_val_text":null,"subject_id":9,"value_float":null,"value_text":null,"year":2010},{"active":null,"breakdown_id":1,"data_set_id":null,"data_type_id":18,"ds_id":84482,"grade":"9","id":null,"level_code":"e,m,h","number_tested":24737,"school_id":1103,"school_val_float":80,"school_val_text":null,"state_val_float":69,"state_val_text":null,"subject_id":11,"value_float":null,"value_text":null,"year":2010},{"active":null,"breakdown_id":1,"data_set_id":null,"data_type_id":19,"ds_id":84488,"grade":"5","id":null,"level_code":"e,m,h","number_tested":24737,"school_id":1103,"school_val_float":80,"school_val_text":null,"state_val_float":69,"state_val_text":null,"subject_id":11,"value_float":null,"value_text":null,"year":2010}]')

      test_data_types = {}
      test_descriptions = {}

      #Only 1 of the data_type_ids in the test_data_sets_and_values has corresponding row in TestDataType table.
      [19].each do |data_type_id|
        test_data_types[data_type_id] = Array(FactoryGirl.build(:test_data_type, id: data_type_id))
        test_descriptions[data_type_id] = Array(FactoryGirl.build(:test_description, data_type_id: data_type_id))
      end
      allow(TestDataType).to receive(:by_ids).with([18,19]).and_return(test_data_types)
      allow(TestDescription).to receive(:by_data_type_ids).with([18,19],school.state).and_return(test_descriptions)

      test_scores_hash = subject.build_test_scores_hash(test_data_sets_and_values,school)

      expect(test_scores_hash.size).to eq(1)
      expect(test_scores_hash[19][:grades].size).to eq(1)
      expect(test_scores_hash[19][:lowest_grade]).to eq(5)
      expect(test_scores_hash[19][:test_description]).to eq("This describes the test")
      expect(test_scores_hash[19][:test_source]).to eq("This is the source of test data")
      expect(test_scores_hash[19][:test_label]).to eq("Awesome Test")
    end

    it 'should empty test scores hash since there are no corresponding data type ids' do
      test_data_sets_and_values = JSON.parse('[{"active":null,"breakdown_id":1,"data_set_id":null,"data_type_id":18,"ds_id":84122,"grade":"9","id":null,"level_code":"e,m,h","number_tested":269697,"school_id":1103,"school_val_float":20,"school_val_text":null,"state_val_float":22,"state_val_text":null,"subject_id":7,"value_float":null,"value_text":null,"year":2010},{"active":null,"breakdown_id":1,"data_set_id":null,"data_type_id":18,"ds_id":84302,"grade":"8","id":null,"level_code":"e,m,h","number_tested":134540,"school_id":1103,"school_val_float":33,"school_val_text":null,"state_val_float":45,"state_val_text":null,"subject_id":9,"value_float":null,"value_text":null,"year":2010},{"active":null,"breakdown_id":1,"data_set_id":null,"data_type_id":18,"ds_id":84482,"grade":"9","id":null,"level_code":"e,m,h","number_tested":24737,"school_id":1103,"school_val_float":80,"school_val_text":null,"state_val_float":69,"state_val_text":null,"subject_id":11,"value_float":null,"value_text":null,"year":2010},{"active":null,"breakdown_id":1,"data_set_id":null,"data_type_id":19,"ds_id":84488,"grade":"5","id":null,"level_code":"e,m,h","number_tested":24737,"school_id":1103,"school_val_float":80,"school_val_text":null,"state_val_float":69,"state_val_text":null,"subject_id":11,"value_float":null,"value_text":null,"year":2010}]')

      # None of the data_type_ids in test_data_sets_and_values have rows in TestDataType table.
      allow(TestDataType).to receive(:by_ids).with([18,19]).and_return({})
      allow(TestDescription).to receive(:by_data_type_ids).with([18,19],school.state).and_return({})

      test_scores_hash = subject.build_test_scores_hash(test_data_sets_and_values,school)

      expect(test_scores_hash).to be_empty
    end

    it 'should empty test scores hash since there are no corresponding data type ids' do
      test_data_sets_and_values = JSON.parse('[{"active":null,"breakdown_id":1,"data_set_id":null,"data_type_id":18,"ds_id":84122,"grade":"9","id":null,"level_code":"e,m,h","number_tested":269697,"school_id":1103,"school_val_float":20,"school_val_text":null,"state_val_float":22,"state_val_text":null,"subject_id":7,"value_float":null,"value_text":null,"year":2010},{"active":null,"breakdown_id":1,"data_set_id":null,"data_type_id":18,"ds_id":84302,"grade":"8","id":null,"level_code":"e,m,h","number_tested":134540,"school_id":1103,"school_val_float":33,"school_val_text":null,"state_val_float":45,"state_val_text":null,"subject_id":9,"value_float":null,"value_text":null,"year":2010},{"active":null,"breakdown_id":1,"data_set_id":null,"data_type_id":18,"ds_id":84482,"grade":"9","id":null,"level_code":"e,m,h","number_tested":24737,"school_id":1103,"school_val_float":80,"school_val_text":null,"state_val_float":69,"state_val_text":null,"subject_id":11,"value_float":null,"value_text":null,"year":2010},{"active":null,"breakdown_id":1,"data_set_id":null,"data_type_id":19,"ds_id":84488,"grade":"5","id":null,"level_code":"e,m,h","number_tested":24737,"school_id":1103,"school_val_float":80,"school_val_text":null,"state_val_float":69,"state_val_text":null,"subject_id":11,"value_float":null,"value_text":null,"year":2010}]')

      # None of the data_type_ids in test_data_sets_and_values have rows in TestDataType table.
      allow(TestDataType).to receive(:by_ids).with([18,19]).and_return(nil)
      allow(TestDescription).to receive(:by_data_type_ids).with([18,19],school.state).and_return(nil)

      test_scores_hash = subject.build_test_scores_hash(test_data_sets_and_values,school)

      expect(test_scores_hash).to be_empty
    end

    it 'should return test scores hash for all the data type ids but with no description and source info' do
      test_data_sets_and_values = JSON.parse('[{"active":null,"breakdown_id":1,"data_set_id":null,"data_type_id":18,"ds_id":84122,"grade":"9","id":null,"level_code":"e,m,h","number_tested":269697,"school_id":1103,"school_val_float":20,"school_val_text":null,"state_val_float":22,"state_val_text":null,"subject_id":7,"value_float":null,"value_text":null,"year":2010},{"active":null,"breakdown_id":1,"data_set_id":null,"data_type_id":18,"ds_id":84302,"grade":"8","id":null,"level_code":"e,m,h","number_tested":134540,"school_id":1103,"school_val_float":33,"school_val_text":null,"state_val_float":45,"state_val_text":null,"subject_id":9,"value_float":null,"value_text":null,"year":2010},{"active":null,"breakdown_id":1,"data_set_id":null,"data_type_id":18,"ds_id":84482,"grade":"9","id":null,"level_code":"e,m,h","number_tested":24737,"school_id":1103,"school_val_float":80,"school_val_text":null,"state_val_float":69,"state_val_text":null,"subject_id":11,"value_float":null,"value_text":null,"year":2010},{"active":null,"breakdown_id":1,"data_set_id":null,"data_type_id":19,"ds_id":84488,"grade":"5","id":null,"level_code":"e,m,h","number_tested":24737,"school_id":1103,"school_val_float":80,"school_val_text":null,"state_val_float":69,"state_val_text":null,"subject_id":11,"value_float":null,"value_text":null,"year":2010}]')
      test_data_types = {}
      #all the data_type_ids in the test_data_sets_and_values have rows in TestDataType table.
      [18,19].each do |data_type_id|
        test_data_types[data_type_id] = Array(FactoryGirl.build(:test_data_type, id: data_type_id))
      end
      allow(TestDataType).to receive(:by_ids).with([18,19]).and_return(test_data_types)

      #No description and source
      allow(TestDescription).to receive(:by_data_type_ids).with([18,19],school.state).and_return(nil)

      test_scores_hash = subject.build_test_scores_hash(test_data_sets_and_values,school)

      expect(test_scores_hash.size).to eq(2)
      expect(test_scores_hash[18][:grades].size).to eq(2)
      expect(test_scores_hash[19][:grades].size).to eq(1)
      expect(test_scores_hash[18][:lowest_grade]).to eq(8)
      expect(test_scores_hash[19][:lowest_grade]).to eq(5)
      expect(test_scores_hash[18][:test_description]).to be_blank
      expect(test_scores_hash[18][:test_source]).to be_blank
      expect(test_scores_hash[18][:test_label]).to eq("Awesome Test")
    end


    it 'should get the right grades from the level code, since grade=all' do
      school.level_code = "e,m"
      test_data_sets_and_values = JSON.parse('[{"active":null,"breakdown_id":1,"data_set_id":null,"data_type_id":18,"ds_id":84122,"grade":"All","id":null,"level_code":"e","number_tested":269697,"school_id":1103,"school_val_float":20,"school_val_text":null,"state_val_float":22,"state_val_text":null,"subject_id":7,"value_float":null,"value_text":null,"year":2010},{"active":null,"breakdown_id":1,"data_set_id":null,"data_type_id":18,"ds_id":84302,"grade":"All","id":null,"level_code":"m,h","number_tested":134540,"school_id":1103,"school_val_float":33,"school_val_text":null,"state_val_float":45,"state_val_text":null,"subject_id":9,"value_float":null,"value_text":null,"year":2010},{"active":null,"breakdown_id":1,"data_set_id":null,"data_type_id":19,"ds_id":84488,"grade":"All","id":null,"level_code":"e,m,h","number_tested":24737,"school_id":1103,"school_val_float":80,"school_val_text":null,"state_val_float":69,"state_val_text":null,"subject_id":11,"value_float":null,"value_text":null,"year":2010}]')
      test_data_types = {}
      #all the data_type_ids in the test_data_sets_and_values have rows in TestDataType table.
      [18,19].each do |data_type_id|
        test_data_types[data_type_id] = Array(FactoryGirl.build(:test_data_type, id: data_type_id))
      end
      allow(TestDataType).to receive(:by_ids).with([18,19]).and_return(test_data_types)

      #No description and source
      allow(TestDescription).to receive(:by_data_type_ids).with([18,19],school.state).and_return(nil)

      test_scores_hash = subject.build_test_scores_hash(test_data_sets_and_values,school)

      expect(test_scores_hash.size).to eq(2)

      expect(test_scores_hash[18][:lowest_grade]).to eq(15)
      expect(test_scores_hash[18][:grades].size).to eq(2)
      expect(test_scores_hash[18][:grades].keys[0].value).to eq(15)
      expect(test_scores_hash[18][:grades].keys[1].value).to eq(16)
      expect(test_scores_hash[18][:grades].values[0][:label]).to eq('Elementary school')
      expect(test_scores_hash[18][:grades].values[1][:label]).to eq('Middle school')

      expect(test_scores_hash[19][:lowest_grade]).to eq(16)
      expect(test_scores_hash[19][:grades].size).to eq(1)
      expect(test_scores_hash[19][:grades].keys[0].value).to eq(16)
      expect(test_scores_hash[19][:grades].values[0][:label]).to eq('Elementary and Middle school')
    end


    it 'should return rounded test scores.' do
      test_data_sets_and_values = JSON.parse('[{"active":null,"breakdown_id":1,"data_set_id":null,"data_type_id":18,"ds_id":84122,"grade":"9","id":null,"level_code":"e,m,h","number_tested":269697,"school_id":1103,"school_val_float":20.415,"school_val_text":null,"state_val_float":22,"state_val_text":null,"subject_id":7,"value_float":null,"value_text":null,"year":2010},{"active":null,"breakdown_id":1,"data_set_id":null,"data_type_id":18,"ds_id":84302,"grade":"8","id":null,"level_code":"e,m,h","number_tested":134540,"school_id":1103,"school_val_float":33,"school_val_text":null,"state_val_float":45,"state_val_text":null,"subject_id":9,"value_float":null,"value_text":null,"year":2010},{"active":null,"breakdown_id":1,"data_set_id":null,"data_type_id":18,"ds_id":84482,"grade":"9","id":null,"level_code":"e,m,h","number_tested":24737,"school_id":1103,"school_val_float":80,"school_val_text":null,"state_val_float":69,"state_val_text":null,"subject_id":11,"value_float":null,"value_text":null,"year":2010},{"active":null,"breakdown_id":1,"data_set_id":null,"data_type_id":19,"ds_id":84488,"grade":"5","id":null,"level_code":"e,m,h","number_tested":24737,"school_id":1103,"school_val_float":80.5,"school_val_text":null,"state_val_float":69,"state_val_text":null,"subject_id":11,"value_float":null,"value_text":null,"year":2010}]')

      test_data_types = {}
      #all the data_type_ids in the test_data_sets_and_values have rows in TestDataType table.
      [18,19].each do |data_type_id|
        test_data_types[data_type_id] = Array(FactoryGirl.build(:test_data_type, id: data_type_id))
      end
      allow(TestDataType).to receive(:by_ids).with([18,19]).and_return(test_data_types)
      allow(TestDescription).to receive(:by_data_type_ids).with([18,19],school.state).and_return(nil)

      test_scores_hash = subject.build_test_scores_hash(test_data_sets_and_values,school)

      expect(test_scores_hash.values[0][:grades].values[0][:level_code].values[0].values[0].values[0]["score"]).to eq (20)
      expect(test_scores_hash.values[1][:grades].values[0][:level_code].values[0].values[0].values[0]["score"]).to eq (81)
    end

    it 'should not try to round test scores if its nil or a string value.' do
      test_data_sets_and_values = JSON.parse('[{"active":null,"breakdown_id":1,"data_set_id":null,"data_type_id":18,"ds_id":84122,"grade":"9","id":null,"level_code":"e,m,h","number_tested":269697,"school_id":1103,"school_val_float":null,"school_val_text":null,"state_val_float":null,"state_val_text":null,"subject_id":7,"value_float":null,"value_text":null,"year":2010},{"active":null,"breakdown_id":1,"data_set_id":null,"data_type_id":18,"ds_id":84302,"grade":"8","id":null,"level_code":"e,m,h","number_tested":134540,"school_id":1103,"school_val_float":null,"school_val_text":"smthing","state_val_float":null,"state_val_text":null,"subject_id":9,"value_float":null,"value_text":null,"year":2010},{"active":null,"breakdown_id":1,"data_set_id":null,"data_type_id":18,"ds_id":84482,"grade":"9","id":null,"level_code":"e,m,h","number_tested":24737,"school_id":1103,"school_val_float":null,"school_val_text":null,"state_val_float":null,"state_val_text":null,"subject_id":11,"value_float":null,"value_text":null,"year":2010},{"active":null,"breakdown_id":1,"data_set_id":null,"data_type_id":19,"ds_id":84488,"grade":"5","id":null,"level_code":"e,m,h","number_tested":24737,"school_id":1103,"school_val_float":null,"school_val_text":"smthing","state_val_float":null,"state_val_text":null,"subject_id":11,"value_float":null,"value_text":null,"year":2010}]')
      test_data_types = {}
      #all the data_type_ids in the test_data_sets_and_values have rows in TestDataType table.
      [18,19].each do |data_type_id|
        test_data_types[data_type_id] = Array(FactoryGirl.build(:test_data_type, id: data_type_id))
      end
      allow(TestDataType).to receive(:by_ids).with([18,19]).and_return(test_data_types)
      allow(TestDescription).to receive(:by_data_type_ids).with([18,19],school.state).and_return(nil)

      test_scores_hash = subject.build_test_scores_hash(test_data_sets_and_values,school)

      expect(test_scores_hash.values[0][:grades].values[0][:level_code].values[0].values[0].values[0]["score"]).to be_blank
      expect(test_scores_hash.values[0][:grades].values[0][:level_code].values[0].values[0].values[0]["state_avg"]).to be_blank
    end

  end

  describe 'sort_test_scores' do
    it 'should sort test scores' do

      test_data_sets_and_values = [{:test_data_type_id => 18, :test_data_set_id => 84122, :grade => "9", :level_code => "e,m,h", :subject_id => 7, :year => 2010, :school_value_text => nil, :school_value_float => 20.0, :state_value_text => nil, :state_value_float => 22.0, :breakdown_id => 1, :number_tested => 269697},
                                   {:test_data_type_id => 19, :test_data_set_id => 84488, :grade => "7", :level_code => "e,m,h", :subject_id => 11, :year => 2010, :school_value_text => nil, :school_value_float => 90.0, :state_value_text => nil, :state_value_float => 77.0, :breakdown_id => 1, :number_tested => 24737},
                                   {:test_data_type_id => 18, :test_data_set_id => 84302, :grade => "9", :level_code => "e,m,h", :subject_id => 7, :year => 2009, :school_value_text => nil, :school_value_float => 33.0, :state_value_text => nil, :state_value_float => 45.0, :breakdown_id => 1, :number_tested => 134540},
                                   {:test_data_type_id => 18, :test_data_set_id => 84302, :grade => "8", :level_code => "e,m,h", :subject_id => 9, :year => 2010, :school_value_text => nil, :school_value_float => 31.0, :state_value_text => nil, :state_value_float => 35.0, :breakdown_id => 1, :number_tested => 134540},
                                   {:test_data_type_id => 18, :test_data_set_id => 84302, :grade => "9", :level_code => "e,m,h", :subject_id => 19, :year => 2009, :school_value_text => nil, :school_value_float => 36.0, :state_value_text => nil, :state_value_float => 55.0, :breakdown_id => 1, :number_tested => 134540},
                                   {:test_data_type_id => 18, :test_data_set_id => 84302, :grade => "10", :level_code => "e,m,h", :subject_id => 19, :year => 2009, :school_value_text => nil, :school_value_float => 38.0, :state_value_text => nil, :state_value_float => 56.0, :breakdown_id => 1, :number_tested => 134540},
                                   {:test_data_type_id => 18, :test_data_set_id => 84482, :grade => "9", :level_code => "e,m,h", :subject_id => 11, :year => 2009, :school_value_text => nil, :school_value_float => 80.0, :state_value_text => nil, :state_value_float => 69.0, :breakdown_id => 1, :number_tested => 24737},
                                   {:test_data_type_id => 19, :test_data_set_id => 84488, :grade => "7", :level_code => "e,m,h", :subject_id => 11, :year => 2009, :school_value_text => nil, :school_value_float => 70.0, :state_value_text => nil, :state_value_float => 68.0, :breakdown_id => 1, :number_tested => 24737},

      ]

      test_data_sets_and_values = JSON.parse('[{"active":null,"breakdown_id":1,"data_set_id":null,"data_type_id":18,"ds_id":84122,"grade":"9","id":null,"level_code":"e,m,h","number_tested":269697,"school_id":1103,"school_val_float":20,"school_val_text":null,"state_val_float":22,"state_val_text":null,"subject_id":7,"value_float":null,"value_text":null,"year":2010},{"active":null,"breakdown_id":1,"data_set_id":null,"data_type_id":19,"ds_id":84488,"grade":"7","id":null,"level_code":"e,m,h","number_tested":24737,"school_id":1103,"school_val_float":90,"school_val_text":"smthing","state_val_float":77,"state_val_text":null,"subject_id":11,"value_float":null,"value_text":null,"year":2010},{"active":null,"breakdown_id":1,"data_set_id":null,"data_type_id":18,"ds_id":84302,"grade":"9","id":null,"level_code":"e,m,h","number_tested":134540,"school_id":1103,"school_val_float":33,"school_val_text":null,"state_val_float":45,"state_val_text":null,"subject_id":7,"value_float":null,"value_text":null,"year":2009},{"active":null,"breakdown_id":1,"data_set_id":null,"data_type_id":18,"ds_id":84302,"grade":"8","id":null,"level_code":"e,m,h","number_tested":134540,"school_id":1103,"school_val_float":31,"school_val_text":null,"state_val_float":35,"state_val_text":null,"subject_id":9,"value_float":null,"value_text":null,"year":2010},{"active":null,"breakdown_id":1,"data_set_id":null,"data_type_id":18,"ds_id":84302,"grade":"9","id":null,"level_code":"e,m,h","number_tested":134540,"school_id":1103,"school_val_float":36,"school_val_text":null,"state_val_float":55,"state_val_text":null,"subject_id":19,"value_float":null,"value_text":null,"year":2009},{"active":null,"breakdown_id":1,"data_set_id":null,"data_type_id":18,"ds_id":84302,"grade":"10","id":null,"level_code":"e,m,h","number_tested":134540,"school_id":1103,"school_val_float":38,"school_val_text":null,"state_val_float":56,"state_val_text":null,"subject_id":19,"value_float":null,"value_text":null,"year":2009},{"active":null,"breakdown_id":1,"data_set_id":null,"data_type_id":18,"ds_id":84482,"grade":"9","id":null,"level_code":"e,m,h","number_tested":24737,"school_id":1103,"school_val_float":80,"school_val_text":null,"state_val_float":56,"state_val_text":69,"subject_id":11,"value_float":null,"value_text":null,"year":2009},{"active":null,"breakdown_id":1,"data_set_id":null,"data_type_id":19,"ds_id":84488,"grade":"7","id":null,"level_code":"e,m,h","number_tested":24737,"school_id":1103,"school_val_float":70,"school_val_text":null,"state_val_float":68,"state_val_text":null,"subject_id":11,"value_float":null,"value_text":null,"year":2009}]')

      test_data_types = {}
      test_descriptions = {}

      [18,19].each do |data_type_id|
        test_data_types[data_type_id] = Array(FactoryGirl.build(:test_data_type, id: data_type_id))
        test_descriptions[data_type_id] = Array(FactoryGirl.build(:test_description, data_type_id: data_type_id))
      end
      allow(TestDataType).to receive(:by_ids).with([18,19]).and_return(test_data_types)
      allow(TestDescription).to receive(:by_data_type_ids).with([18,19],school.state).and_return(test_descriptions)
      test_scores_hash = subject.build_test_scores_hash(test_data_sets_and_values,school)

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
      expect(sorted_test_scores.values[1][:grades].values[1][:level_code].values[0].keys[0]).to eq ("algebra 1")
      expect(sorted_test_scores.values[1][:grades].values[1][:level_code].values[0].keys[1]).to eq ("algebra 2")
      expect(sorted_test_scores.values[1][:grades].values[1][:level_code].values[0].keys[2]).to eq ("english")

      #years are sorted in descending order.
      expect(sorted_test_scores.values[1][:grades].values[1][:level_code].values[0].values[0].keys[0]).to eq (2010)
      expect(sorted_test_scores.values[1][:grades].values[1][:level_code].values[0].values[0].keys[1]).to eq (2009)

    end
  end

end
