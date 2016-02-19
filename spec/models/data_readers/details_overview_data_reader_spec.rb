require 'spec_helper'

describe DetailsOverviewDataReader do

  subject { DetailsOverviewDataReader.new(nil) }

  let(:category_data) do
    [
      FactoryGirl.build(
        :category_data,
        response_key: 'fac',
        label: 'Facilities',
        key_type: 'esp_response'
      ),
      FactoryGirl.build(
        :category_data,
        response_key: 'foreign_language',
        label: 'Foreign language',
        key_type: 'esp_response'
      ),
      FactoryGirl.build(
        :category_data,
        response_key: 'Ethnicity',
        label: 'Student ethnicity',
        key_type: 'census_data'
      ),
      FactoryGirl.build(
        :category_data,
        response_key: 'English learners',
        label: 'English language learners',
        key_type: 'census_data'
      )
    ]
  end


  let(:sample_data) do
    {
      "esp_responses" => {
        "fac" =>  
          {"sports_fields"=> {"member_id"=>5893684,
                            "source"=>"osp",
                            "created"=>"2015-07-31T22:25:47-07:00" },
          "audiovisual"=> {"member_id"=>5893684,
                          "source"=>"osp",
                          "created"=>"2015-07-31T22:25:47-07:00" },
          "cafeteria"=> {"member_id"=>5893684,
                        "source"=>"osp",
                        "created"=>"2015-07-31T22:25:47-07:00" }
          },
        "foreign_language" => 
          {"mandarin"=> {"member_id"=>5893684,
                        "source"=>"osp",
                        "created"=>"2015-07-31T22:25:47-07:00"}
        }, 
      },
      "characteristics"=> {
      "English learners"=> [
        {"breakdown"=>"All students",
         "original_breakdown"=>"All students",
         "created"=>"2014-07-25T10:20:09-07:00",
         "school_value"=>77.3,
         "source"=>"CA Dept. of Education",
         "year"=>2014,
         "state_average_2012"=>23.0,
         "school_value_2014"=>14.6465}
      ],
      "Ethnicity"=> 
      [
        {"breakdown"=>"Asian",
         "original_breakdown"=>"Asian",
         "created"=>"2014-07-25T10:20:09-07:00",
         "school_value"=>57.5758,
         "source"=>"CA Dept. of Education",
         "year"=>2014,
         "school_value_2011"=>56.4246,
         "state_average_2011"=>11.071,
         "school_value_2014"=>57.5758
      },
      {"breakdown"=>"Hispanic",
       "original_breakdown"=>"Hispanic",
       "created"=>"2014-07-25T10:20:09-07:00",
       "school_value"=>24.2424,
       "source"=>"CA Dept. of Education",
       "year"=>2014,
       "school_value_2011"=>24.581,
       "state_average_2011"=>51.4939,
       "school_value_2012"=>24.7059,
       "state_average_2012"=>52.0,
       "school_value_2014"=>24.2424
      },
      {"breakdown"=>"Black",
       "original_breakdown"=>"African American",
       "created"=>"2014-07-25T10:20:09-07:00",
       "school_value"=>8.0808,
       "source"=>"CA Dept. of Education",
       "year"=>2014,
       "school_value_2011"=>13.4078,
       "state_average_2011"=>6.63967,
       "school_value_2012"=>12.9412,
       "state_average_2012"=>6.0,
       "school_value_2014"=>8.08081
      },
      {"breakdown"=>"Pacific Islander",
       "original_breakdown"=>"Pacific Islander",
       "created"=>"2014-07-25T10:20:09-07:00",
       "school_value"=>3.0303,
       "source"=>"CA Dept. of Education",
       "year"=>2014,
       "school_value_2014"=>3.0303
      },
      {"breakdown"=>"White",
       "original_breakdown"=>"White",
       "created"=>"2014-07-25T10:20:09-07:00",
       "school_value"=>2.52525,
       "source"=>"CA Dept. of Education",
       "year"=>2014,
       "school_value_2011"=>1.67598,
       "state_average_2011"=>26.6216,
       "school_value_2012"=>1.56863,
       "state_average_2012"=>26.0,
       "school_value_2014"=>2.52525
      },
      {"breakdown"=>"Two or more races",
       "original_breakdown"=>"Multiracial",
       "created"=>"2014-07-25T10:20:09-07:00",
       "school_value"=>1.51515,
       "source"=>"CA Dept. of Education",
       "year"=>2014,
       "school_value_2011"=>1.11732,
       "state_average_2011"=>2.89175,
       "school_value_2012"=>1.56863,
       "state_average_2012"=>3.0,
       "school_value_2014"=>1.51515
      },
      {"breakdown"=>"Filipino",
       "original_breakdown"=>"Filipino",
       "created"=>"2014-07-25T10:20:09-07:00",
       "school_value"=>1.51515,
       "source"=>"CA Dept. of Education",
       "year"=>2014,
       "school_value_2014"=>1.51515
      }
      ]
    }
    }
  end 


  let(:characteristics_data_only) do
    {
      "characteristics"=> {
      "English learners"=> [
        {"breakdown"=>"All students",
         "original_breakdown"=>"All students",
         "created"=>"2014-07-25T10:20:09-07:00",
         "school_value"=>77.3,
         "source"=>"CA Dept. of Education",
         "year"=>2014,
         "state_average_2012"=>23.0,
         "school_value_2014"=>14.6465}
      ],
      "Ethnicity"=> 
      [
        {"breakdown"=>"Asian",
         "original_breakdown"=>"Asian",
         "created"=>"2014-07-25T10:20:09-07:00",
         "school_value"=>57.5758,
         "source"=>"CA Dept. of Education",
         "year"=>2014,
         "school_value_2011"=>56.4246,
         "state_average_2011"=>11.071,
         "school_value_2014"=>57.5758
      },
      {"breakdown"=>"Hispanic",
       "original_breakdown"=>"Hispanic",
       "created"=>"2014-07-25T10:20:09-07:00",
       "school_value"=>24.2424,
       "source"=>"CA Dept. of Education",
       "year"=>2014,
       "school_value_2011"=>24.581,
       "state_average_2011"=>51.4939,
       "school_value_2012"=>24.7059,
       "state_average_2012"=>52.0,
       "school_value_2014"=>24.2424
      },
      {"breakdown"=>"Black",
       "original_breakdown"=>"African American",
       "created"=>"2014-07-25T10:20:09-07:00",
       "school_value"=>8.0808,
       "source"=>"CA Dept. of Education",
       "year"=>2014,
       "school_value_2011"=>13.4078,
       "state_average_2011"=>6.63967,
       "school_value_2012"=>12.9412,
       "state_average_2012"=>6.0,
       "school_value_2014"=>8.08081
      },
      {"breakdown"=>"Pacific Islander",
       "original_breakdown"=>"Pacific Islander",
       "created"=>"2014-07-25T10:20:09-07:00",
       "school_value"=>3.0303,
       "source"=>"CA Dept. of Education",
       "year"=>2014,
       "school_value_2014"=>3.0303
      },
      {"breakdown"=>"White",
       "original_breakdown"=>"White",
       "created"=>"2014-07-25T10:20:09-07:00",
       "school_value"=>2.52525,
       "source"=>"CA Dept. of Education",
       "year"=>2014,
       "school_value_2011"=>1.67598,
       "state_average_2011"=>26.6216,
       "school_value_2012"=>1.56863,
       "state_average_2012"=>26.0,
       "school_value_2014"=>2.52525
      },
      {"breakdown"=>"Two or more races",
       "original_breakdown"=>"Multiracial",
       "created"=>"2014-07-25T10:20:09-07:00",
       "school_value"=>1.51515,
       "source"=>"CA Dept. of Education",
       "year"=>2014,
       "school_value_2011"=>1.11732,
       "state_average_2011"=>2.89175,
       "school_value_2012"=>1.56863,
       "state_average_2012"=>3.0,
       "school_value_2014"=>1.51515
      },
      {"breakdown"=>"Filipino",
       "original_breakdown"=>"Filipino",
       "created"=>"2014-07-25T10:20:09-07:00",
       "school_value"=>1.51515,
       "source"=>"CA Dept. of Education",
       "year"=>2014,
       "school_value_2014"=>1.51515
      }
      ]
    }
    }
  end 

  let(:esp_data_only) do
    {
      "esp_responses" => {
        "fac" =>
          {"sports_fields"=> {"member_id"=>5893684,
                            "source"=>"osp",
                            "created"=>"2015-07-31T22:25:47-07:00" },
          "audiovisual"=> {"member_id"=>5893684,
                          "source"=>"osp",
                          "created"=>"2015-07-31T22:25:47-07:00" },
          "cafeteria"=> {"member_id"=>5893684,
                        "source"=>"osp",
                        "created"=>"2015-07-31T22:25:47-07:00" }
          },
        "foreign_language" =>
          {"mandarin"=> {"member_id"=>5893684,
                        "source"=>"osp",
                        "created"=>"2015-07-31T22:25:47-07:00"}
        }
      }
    }
  end

  let(:sample_data_missing_school_value_for_breakdown) do
    {

      "esp_responses" => {
        "fac" =>  
          {"sports_fields"=> {"member_id"=>5893684,
                            "source"=>"osp",
                            "created"=>"2015-07-31T22:25:47-07:00" }
        }, 
        "foreign_language" => 
          {"mandarin"=> {"member_id"=>5893684,
                        "source"=>"osp",
                        "created"=>"2015-07-31T22:25:47-07:00"}
        } 
      },
      "characteristics"=> {
      "English learners"=> [
        {"breakdown"=>"All students",
         "original_breakdown"=>"All students",
         "created"=>"2014-07-25T10:20:09-07:00",
         "school_value"=>77.3,
         "source"=>"CA Dept. of Education",
         "year"=>2014,
         "state_average_2012"=>23.0,
         "school_value_2014"=>14.6465}
      ],
# Ethnicity data with hispanic breakdown missing school_value
      "Ethnicity"=>
      [
        {"breakdown"=>"Asian",
         "original_breakdown"=>"Asian",
         "created"=>"2014-07-25T10:20:09-07:00",
         "school_value"=>57.5758,
         "source"=>"CA Dept. of Education",
         "year"=>2014,
         "school_value_2011"=>56.4246,
         "state_average_2011"=>11.071,
         "school_value_2014"=>57.5758
      },
      {"breakdown"=>"Hispanic",
       "original_breakdown"=>"Hispanic",
       "created"=>"2014-07-25T10:20:09-07:00",
       "school_value"=>43.2424,
       "source"=>"CA Dept. of Education",
       "year"=>2014,
       "school_value_2011"=>24.581,
       "state_average_2011"=>51.4939,
       "school_value_2012"=>24.7059,
       "state_average_2012"=>52.0,
       "school_value_2014"=>24.2424
      },
      {"breakdown"=>"Black",
       "original_breakdown"=>"African American",
       "created"=>"2014-07-25T10:20:09-07:00",
       "source"=>"CA Dept. of Education",
       "year"=>2014,
       "school_value_2011"=>13.4078,
       "state_average_2011"=>6.63967,
       "school_value_2012"=>12.9412,
       "state_average_2012"=>6.0,
       "school_value_2014"=>8.08081
      }
        ]
    }
    }
  end

  let(:sample_label_map) { Hash[sample_data.map { |k,v| [[k.first.to_s, nil],"#{k} label"] }] }
  let(:fake_category) do
    double(keys: sample_data.keys,
           key_label_map: sample_label_map, 
           parsed_json_config: {}.with_indifferent_access,
           category_data: category_data
          )
  end

  let(:characteristics_and_osp_data) do
    {
    "esp_responses" => {
        "fac" =>  
          {"sports_fields"=> {"member_id"=>5893684,
                            "source"=>"osp",
                            "created"=>"2015-07-31T22:25:47-07:00" },
          "audiovisual"=> {"member_id"=>5893684,
                          "source"=>"osp",
                          "created"=>"2015-07-31T22:25:47-07:00" },
          "cafeteria"=> {"member_id"=>5893684,
                        "source"=>"osp",
                        "created"=>"2015-07-31T22:25:47-07:00" }
          }
    },
      "characteristics"=> {
      "English learners"=> [
        {"breakdown"=>"All students",
         "original_breakdown"=>"All students",
         "created"=>"2014-07-25T10:20:09-07:00",
         "school_value"=>77.3,
         "source"=>"CA Dept. of Education",
         "year"=>2014,
         "state_average_2012"=>23.0,
         "school_value_2014"=>14.6465}],
     "Ethnicity"=>
      [
        {"breakdown" =>"White",
         "original_breakdown" =>"White",
         "created" =>"2014-07-25T10:20:09-07:00",
         "school_value" =>98.0,
         "source" =>"CA Dept. of Education",
         "year" =>2014,
         "school_value_2011" =>1.67598,
         "state_average_2011" =>26.6216,
         "school_value_2012" =>1.56863,
         "state_average_2012" =>26.0,
         "school_value_2014" =>2.52525
      },
      {"breakdown" =>"Filipino",
       "original_breakdown" =>"Filipino",
       "created" =>"2014-07-25T10:20:09-07:00",
       "school_value" =>2.00,
       "source" =>"CA Dept. of Education",
       "year" =>2014,
       "school_value_2014" =>1.51515
      }
      ]
    }
    }
  end

  describe '#data_for_category' do
    before do
      allow(subject).to receive(:category).and_return(fake_category)
      allow(fake_category).to receive(:category_data).and_return(category_data)
    end
    context 'with valid data' do
      before do
        allow(subject).to receive(:all_school_cache_data_raw).and_return(sample_data)
      end
      let(:results) do
        {
          "Facilities"=>['sports_fields', 'audiovisual', 'cafeteria'],
          "Foreign language"=>['mandarin'],
          "English language learners"=>{"All Students"=> 77.3},
          "Student ethnicity"=>{"Asian"=>57.5758,"Hispanic"=>24.2424, "Black"=>8.0808, "Pacific Islander"=>3.0303, "White"=>2.52525, "Two or more races"=>1.51515, "Filipino"=>1.51515 }
        }
      end
      it 'it should create a CombineCharactersisticsAndEspResponsesData' do 
        expect(DetailsOverviewDataReader::CombineCharacteristicsAndEspResponsesData).
          to receive(:new).once
        subject.data_for_category(fake_category)
      end
      it 'it should return a hash' do 
        expect(subject.data_for_category(fake_category)).to be_a Hash
      end
      it 'should return correctedly formatted data' do
        expect(Hash[subject.data_for_category(fake_category)]).to eq(Hash[results.sort])
      end
    end
    context 'with only esp_responses data' do
      before do
        allow(subject).to receive(:all_school_cache_data_raw).and_return(esp_data_only)
      end
      let(:results) do
        {
          "Facilities"=>['sports_fields', 'audiovisual', 'cafeteria'],
          "Foreign language"=>['mandarin']
        }
      end
      it 'it should return a hash' do
        expect(subject.data_for_category(fake_category)).to be_a Hash
      end
      it 'should return correctedly formatted data' do
        expect(Hash[subject.data_for_category(fake_category)]).to eq(Hash[results.sort])
      end
    end

    context 'with only characteristics data' do
      before do
        allow(subject).to receive(:all_school_cache_data_raw).and_return(characteristics_data_only)
      end
      let(:results) do
        {
          "English language learners"=>{"All Students"=> 77.3},
          "Student ethnicity"=>{"Asian"=>57.5758,"Hispanic"=>24.2424, "Black"=>8.0808, "Pacific Islander"=>3.0303, "White"=>2.52525, "Two or more races"=>1.51515, "Filipino"=>1.51515 }
        }
      end
      it 'it should return a hash' do 
        expect(subject.data_for_category(fake_category)).to be_a Hash
      end
      it 'should return correctedly formatted data' do
        expect(Hash[subject.data_for_category(fake_category)]).to eq(Hash[results.sort])
      end
    end

    context 'with nil cache data' do
      before do
        allow(subject).to receive(:all_school_cache_data_raw).and_return(nil)
      end
      it 'it should return an empty hash' do 
        expect(subject.data_for_category(fake_category)).to eq({})
       end
    end

    context 'with Ethnicity data that has breakdown without school value' do
      before do
        allow(subject).to receive(:all_school_cache_data_raw).and_return(sample_data_missing_school_value_for_breakdown)
      end
      let(:results_missing_one_breakdown) do
        {

          "Facilities"=>['sports_fields'],
          "Foreign language"=>['mandarin'],
          "English language learners"=>{"All Students"=> 77.3},
          "Student ethnicity"=>{"Asian"=>57.5758,"Hispanic"=>43.2424 }
        }
      end
      it 'it should return a hash' do 
        expect(subject.data_for_category(fake_category)).to be_a Hash
      end
      it 'it should create a CombineCharactersisticsAndEspResponsesData' do 
        expect(DetailsOverviewDataReader::CombineCharacteristicsAndEspResponsesData).
          to receive(:new).once
        subject.data_for_category(fake_category)
      end
      it 'it should return hash with correctly formatted data that had no errors' do
        expect(Hash[subject.data_for_category(fake_category)]).to eq(Hash[results_missing_one_breakdown.sort])
      end
    end
  end

  describe DetailsOverviewDataReader::CombineCharacteristicsAndEspResponsesData do
      let(:charactersitics_and_osp_results) {
        {
          "Facilities"=>['sports_fields', 'audiovisual', 'cafeteria'],
          "English language learners"=>{"All Students"=> 77.3},
          "Student ethnicity"=>{"White"=>98.00,"Filipino"=>2.00}
        }
      }
    context 'with characteristics and osp data' do
      subject { DetailsOverviewDataReader::CombineCharacteristicsAndEspResponsesData.new(fake_category, characteristics_and_osp_data) }
      it 'should return correctly formatted data' do
        expect(Hash[subject.run.sort]).to eq(Hash[charactersitics_and_osp_results.sort])
      end
    end
  end
end

