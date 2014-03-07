require 'spec_helper'

describe RatingsHelper do

  let(:school) { School.new(id: 1, state: 'mi', city: 'Detroit') }

  it 'should call TestDataSet.by_data_type_ids with all the data type ids in the configuration' do
    RatingsConfiguration.stub(:fetch_city_rating_data_type_ids).with(school).and_return([200,198,199,201])
    RatingsConfiguration.stub(:fetch_state_rating_data_type_ids).with(school).and_return([197])
    RatingsConfiguration.stub(:fetch_gs_rating_data_type_ids).and_return([164,165,166])
    #No prek ratings
    RatingsConfiguration.stub(:fetch_preK_rating_data_type_ids).and_return([])
    TestDataSet.stub(:by_data_type_ids).with(school, [200,198,199,201,197,164,165,166]).and_return({})
    expect(RatingsHelper.fetch_ratings_for_school school).to  be_empty
  end

  #There is no configuration,and no rating results. Hence expect empty state ratings
  it 'should return empty state ratings' do
    RatingsConfiguration.stub(:fetch_state_rating_configuration).with(school).and_return({})
    RatingsConfiguration.stub(:fetch_state_rating_data_type_ids).with(school).and_return([])

    #There is no description
    DataDescription.stub(:lookup_table).and_return({})

    expect(RatingsHelper.construct_state_ratings({}, school)).to be_empty
  end

  #There are rating results but there is no configuration. Hence expect empty state ratings
  it 'should return empty state ratings' do
    RatingsConfiguration.stub(:fetch_state_rating_configuration).with(school).and_return({})
    RatingsConfiguration.stub(:fetch_state_rating_data_type_ids).with(school).and_return([])

    #There is no description
    DataDescription.stub(:lookup_table).and_return({})

    rating_results = build_rating_results_for_state

    expect(RatingsHelper.construct_state_ratings(rating_results, school)).to be_empty
  end

  #There is configuration but there are no rating results. Hence expect empty state ratings
  it 'should return empty state ratings' do
    RatingsConfiguration.stub(:fetch_state_rating_configuration).with(school).and_return(Hashie::Mash.new({overall: {data_type_id: 197, description_key: "mi_state_accountability_summary"}}))
    RatingsConfiguration.stub(:fetch_state_rating_data_type_ids).with(school).and_return([197])

    #There is no description
    DataDescription.stub(:lookup_table).and_return({})

    expect(RatingsHelper.construct_state_ratings({}, school)).to be_empty
  end

  #There is a configuration and rating results.
  it 'should return overall state rating but no description' do
    RatingsConfiguration.stub(:fetch_state_rating_configuration).with(school).and_return(Hashie::Mash.new({overall: {data_type_id: 197, description_key: "mi_state_accountability_summary"}}))
    RatingsConfiguration.stub(:fetch_state_rating_data_type_ids).with(school).and_return([197])

    #There is no description
    DataDescription.stub(:lookup_table).and_return({})

    rating_results = build_rating_results_for_state

    expect(RatingsHelper.construct_state_ratings(rating_results, school)).to eq({"overall_rating"=>"1", "description"=>nil})
  end

  #There is a configuration and rating results.
  it 'should return overall state rating and description' do
    RatingsConfiguration.stub(:fetch_state_rating_configuration).with(school).and_return(Hashie::Mash.new({overall: {data_type_id: 197, description_key: "mi_state_accountability_summary"}}))
    RatingsConfiguration.stub(:fetch_state_rating_data_type_ids).with(school).and_return([197])

    #There is a description
    DataDescription.stub(:lookup_table).and_return({"mi_state_accountability_summary" => "some summary"})

    rating_results = build_rating_results_for_state

    expect(RatingsHelper.construct_state_ratings(rating_results, school)).to eq({"overall_rating"=>"1", "description"=>"some summary"})
  end

  def build_rating_results_for_state
    rating_results = []

    state_rating_data_type_ids = [197]
    state_rating_data_type_ids.each do |data_type_id|
      rating_results += FactoryGirl.build_list(:test_data_set_for_state_ratings, 1, data_type_id: data_type_id)
    end
    rating_results
  end

  #There is a no configuration and no rating results. Hence expect empty city rating.
  it 'should return empty city rating' do
    RatingsConfiguration.stub(:fetch_city_rating_configuration).with(school).and_return({})
    RatingsConfiguration.stub(:fetch_city_rating_data_type_ids).with(school).and_return([])

    #There is no description
    DataDescription.stub(:lookup_table).and_return({})

    expect(RatingsHelper.construct_city_ratings({}, school)).to be_empty
  end

  #There are rating results but there is no configuration. Hence expect empty city rating.
  it 'should return empty city rating' do
    RatingsConfiguration.stub(:fetch_city_rating_configuration).with(school).and_return({})
    RatingsConfiguration.stub(:fetch_city_rating_data_type_ids).with(school).and_return([])

    #There is no description
    DataDescription.stub(:lookup_table).and_return({})

    rating_results = build_rating_results_for_city

    expect(RatingsHelper.construct_city_ratings(rating_results, school)).to be_empty
  end

  #There is configuration but there are no rating results. Hence expect empty city rating.
  it 'should return empty city rating' do
    RatingsConfiguration.stub(:fetch_city_rating_configuration).with(school).and_return(Hashie::Mash.new({rating_breakdowns: {
        climate: {data_type_id: 200, label: "School Climate"},
        status: {data_type_id: 198, label: "Academic Status"},
        progress: {data_type_id: 199, label: "Academic Progress"}
    },overall: {data_type_id: 201, label: "overall", description_key: "mi_esd_summary"}}))
    RatingsConfiguration.stub(:fetch_city_rating_data_type_ids).with(school).and_return([200,198,199,201])

    #There is no description
    DataDescription.stub(:lookup_table).and_return({})

    expect(RatingsHelper.construct_city_ratings({}, school)).to be_empty
  end

  #There is configuration and rating results.
  it 'should return overall city rating, description and label' do
    RatingsConfiguration.stub(:fetch_city_rating_configuration).with(school).and_return(Hashie::Mash.new({rating_breakdowns: {
        climate: {data_type_id: 200, label: "School Climate"},
        status: {data_type_id: 198, label: "Academic Status"},
        progress: {data_type_id: 199, label: "Academic Progress"}
    },overall: {data_type_id: 201, label: "overall", description_key: "mi_esd_summary"}}))
    RatingsConfiguration.stub(:fetch_city_rating_data_type_ids).with(school).and_return([200,198,199,201])

    #To this to get the display_name.
    #TODO: I could not get factory girl to build this association while constructing the testdatasets due to db sharding.How to solve this?
    TestDataSet.any_instance.stub(:test_data_type).and_return(FactoryGirl.build(:test_data_type, id: 201))

    #There is a description
    DataDescription.stub(:lookup_table).and_return({"mi_esd_summary" => "some summary"})

    rating_results = build_rating_results_for_city

    expect(RatingsHelper.construct_city_ratings(rating_results, school)).to eq({"overall_rating"=>"1",
                                                                                "description"=>"some summary", "city_rating_label"=>"Awesome Test", "rating_breakdowns"=>{"School Climate"=>"1", "Academic Status"=>"1", "Academic Progress"=>"1"}})
  end

  #There is configuration and rating results.But there is no result for overall rating. Hence expect empty city rating.
  it 'should return empty city rating' do
    RatingsConfiguration.stub(:fetch_city_rating_configuration).with(school).and_return(Hashie::Mash.new({rating_breakdowns: {
        climate: {data_type_id: 200, label: "School Climate"},
        status: {data_type_id: 198, label: "Academic Status"},
        progress: {data_type_id: 199, label: "Academic Progress"}
    },overall: {data_type_id: 201, label: "overall", description_key: "mi_esd_summary"}}))
    RatingsConfiguration.stub(:fetch_city_rating_data_type_ids).with(school).and_return([200,198,199,201])

    #There is a description
    DataDescription.stub(:lookup_table).and_return({"mi_esd_summary" => "some summary"})

    #The rating results do not have an overall rating
    rating_results = build_rating_results_for_city_no_overall

    expect(RatingsHelper.construct_city_ratings(rating_results, school)).to eq({})
  end

  def build_rating_results_for_city
    rating_results = []

    city_rating_data_type_ids = [200,198,199,201]
    city_rating_data_type_ids.each do |data_type_id|
      rating_results += FactoryGirl.build_list(:test_data_set_for_city_ratings, 1, data_type_id: data_type_id)
    end

    rating_results
  end

  def build_rating_results_for_city_no_overall
    rating_results = []

    city_rating_data_type_ids = [200,198,199]
    city_rating_data_type_ids.each do |data_type_id|
      rating_results += FactoryGirl.build_list(:test_data_set_for_city_ratings, 1, data_type_id: data_type_id)
    end
    rating_results
  end

  #There is a no configuration and no rating results. Hence expect empty preK rating.
  it 'should return empty preK rating' do
    RatingsConfiguration.stub(:fetch_preK_rating_configuration).with(school).and_return({})
    RatingsConfiguration.stub(:fetch_preK_rating_data_type_ids).with(school).and_return([])

    #There is no description
    DataDescription.stub(:lookup_table).and_return({})

    expect(RatingsHelper.construct_preK_ratings({}, school)).to be_empty
  end

  #There are rating results but there is no configuration. Hence expect empty preK rating.
  it 'should return empty preK rating' do
    RatingsConfiguration.stub(:fetch_preK_rating_configuration).with(school).and_return({})
    RatingsConfiguration.stub(:fetch_preK_rating_data_type_ids).with(school).and_return([])

    #There is no description
    DataDescription.stub(:lookup_table).and_return({})

    rating_results = build_rating_results_for_preK

    expect(RatingsHelper.construct_preK_ratings(rating_results, school)).to be_empty
  end

  #There is configuration but there are no rating results. Hence expect empty preK rating.
  it 'should return empty preK rating' do
    RatingsConfiguration.stub(:fetch_preK_rating_configuration).with(school).and_return(
        Hashie::Mash.new({star_rating: {data_type_id: 217, description_key: "mi_prek_star_rating_summary"}}))
    RatingsConfiguration.stub(:fetch_preK_rating_data_type_ids).with(school).and_return([217])

    #There is no description
    DataDescription.stub(:lookup_table).and_return({})

    expect(RatingsHelper.construct_preK_ratings({}, school)).to be_empty
  end

  #There is configuration and rating results.
  it 'should return star preK rating, description and label' do
    TestDataSet.any_instance.stub(:test_data_type).and_return(TestDataType.new)
    RatingsConfiguration.stub(:fetch_preK_rating_configuration).with(school).and_return(
        Hashie::Mash.new({star_rating: {data_type_id: 217, description_key: "mi_prek_star_rating_summary"}}))
    RatingsConfiguration.stub(:fetch_preK_rating_data_type_ids).with(school).and_return([217])

    #To this to get the display_name.
    #TODO: I could not get factory girl to build this association while constructing the testdatasets due to db sharding.How to solve this?
    TestDataSet.any_instance.stub(:test_data_type).and_return(FactoryGirl.build(:test_data_type, id: 217))

    #There is a description
    DataDescription.stub(:lookup_table).and_return({"mi_prek_star_rating_summary" => "some summary"})

    rating_results = build_rating_results_for_preK

    expect(RatingsHelper.construct_preK_ratings(rating_results, school)).to eq({"star_rating"=>1, "description"=>"some summary", "preK_rating_label"=>"Awesome Test"})
  end

  def build_rating_results_for_preK
    rating_results = []

    preK_rating_data_type_ids = [217]
    preK_rating_data_type_ids.each do |data_type_id|
      rating_results += FactoryGirl.build_list(:test_data_set_for_preK_ratings, 1, data_type_id: data_type_id)
    end

    rating_results
  end

end