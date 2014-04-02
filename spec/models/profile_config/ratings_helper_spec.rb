require 'spec_helper'

describe RatingsHelper do

  let(:school) { School.new(id: 1, state: 'mi', city: 'Detroit') }
  let(:school_metadata) { Hashie::Mash.new(overallRating: "1")}

  #it 'should call TestDataSet.by_data_type_ids with all the data type ids in the configuration' do
  #  RatingsConfiguration.stub(:fetch_city_rating_data_type_ids).with(school).and_return([200,198,199,201])
  #  RatingsConfiguration.stub(:fetch_state_rating_data_type_ids).with(school).and_return([197])
  #  RatingsConfiguration.stub(:fetch_gs_rating_data_type_ids).and_return([164,165,166])
  #  #No prek ratings
  #  RatingsConfiguration.stub(:fetch_preK_rating_data_type_ids).and_return([])
  #  TestDataSet.stub(:by_data_type_ids).with(school, [200,198,199,201,197,164,165,166]).and_return({})
  #  expect(RatingsHelper.fetch_ratings_for_school school).to  be_empty
  #end

  #There is no configuration,and no rating results. Hence expect empty state ratings
  it 'should return empty state ratings' do
    ratings_config = RatingsConfiguration.new(nil, nil, nil, nil)

    ratings_helper = RatingsHelper.new([],ratings_config)

    #There is no description
    DataDescription.stub(:lookup_table).and_return({})

    expect(ratings_helper.construct_state_ratings(school)).to be_empty
  end

  #There are rating results but there is no configuration. Hence expect empty state ratings
  it 'should return empty state ratings' do
    ratings_config = RatingsConfiguration.new(nil, nil, nil, nil)
    rating_results = build_rating_results_for_state

    ratings_helper = RatingsHelper.new(rating_results,ratings_config)

    #There is no description
    DataDescription.stub(:lookup_table).and_return({})

    expect(ratings_helper.construct_state_ratings(school)).to be_empty
  end

  #There is configuration but there are no rating results. Hence expect empty state ratings
  it 'should return empty state ratings' do
    state_rating_config = JSON.parse('{"overall":{"data_type_id":197,"description_key":"mi_state_accountability_summary"}}')
    ratings_config = RatingsConfiguration.new(nil, state_rating_config, nil, nil)

    ratings_helper = RatingsHelper.new([],ratings_config)

    #There is no description
    DataDescription.stub(:lookup_table).and_return({})

    expect(ratings_helper.construct_state_ratings(school)).to be_empty
  end

  #There is a configuration and rating results.
  it 'should return overall state rating but no description' do
    state_rating_config = JSON.parse('{"overall":{"data_type_id":197,"description_key":"mi_state_accountability_summary"}}')

    ratings_config = RatingsConfiguration.new(nil, state_rating_config, nil, nil)
    rating_results = build_rating_results_for_state

    ratings_helper = RatingsHelper.new(rating_results,ratings_config)

    #There is no description
    DataDescription.stub(:lookup_table).and_return({})

    expect(ratings_helper.construct_state_ratings(school)).to eq({"overall_rating"=>"1", "description"=>nil})
  end

  #There is a configuration and rating results.
  it 'should return overall state rating and description' do
    state_rating_config = JSON.parse('{"overall":{"data_type_id":197,"description_key":"mi_state_accountability_summary"}}')
    ratings_config = RatingsConfiguration.new(nil, state_rating_config, nil, nil)
    rating_results = build_rating_results_for_state

    ratings_helper = RatingsHelper.new(rating_results,ratings_config)

    #There is a description
    DataDescription.stub(:lookup_table).and_return({[school.state.upcase,"mi_state_accountability_summary"] => "some summary"})

    expect(ratings_helper.construct_state_ratings(school)).to eq({"overall_rating"=>"1", "description"=>"some summary"})
  end

  def build_rating_results_for_state
    rating_results = []

    state_rating_data_type_ids = [197]
    state_rating_data_type_ids.each do |data_type_id|
      rating_results += FactoryGirl.build_list(:ratings_test_data_set, 1, data_type_id: data_type_id)
    end
    rating_results
  end

  #There is a no configuration and no rating results. Hence expect empty city rating.
  it 'should return empty city rating' do
    ratings_config = RatingsConfiguration.new(nil, nil, nil, nil)

    ratings_helper = RatingsHelper.new([],ratings_config)

    #There is no description
    DataDescription.stub(:lookup_table).and_return({})

    expect(ratings_helper.construct_city_ratings(school)).to be_empty
  end

  #There are rating results but there is no configuration. Hence expect empty city rating.
  it 'should return empty city rating' do
    ratings_config = RatingsConfiguration.new(nil, nil, nil, nil)
    rating_results = build_rating_results_for_city

    ratings_helper = RatingsHelper.new(rating_results,ratings_config)

    #There is no description
    DataDescription.stub(:lookup_table).and_return({})

    expect(ratings_helper.construct_city_ratings(school)).to be_empty
  end

  #There is configuration but there are no rating results. Hence expect empty city rating.
  it 'should return empty city rating' do
    city_rating_config = JSON.parse('{"rating_breakdowns":{"climate":{"data_type_id": 200,"label": "School Climate"},"status":{"data_type_id":198,"label": "Academic Status"},"progress":{"data_type_id":199,"label":"Academic Progress"}},"overall":{"data_type_id":201,"label": "overall","description_key": "mi_esd_summary"}}')
    ratings_config = RatingsConfiguration.new(city_rating_config, nil, nil, nil)

    ratings_helper = RatingsHelper.new([],ratings_config)

    #There is no description
    DataDescription.stub(:lookup_table).and_return({})

    expect(ratings_helper.construct_city_ratings(school)).to be_empty
  end

  #There is configuration and rating results.
  it 'should return overall city rating, description and label' do
    city_rating_config = JSON.parse('{"rating_breakdowns":{"climate":{"data_type_id": 200,"label": "School Climate"},"status":{"data_type_id":198,"label": "Academic Status"},"progress":{"data_type_id":199,"label":"Academic Progress"}},"overall":{"data_type_id":201,"label": "overall","description_key": "mi_esd_summary"}}')
    ratings_config = RatingsConfiguration.new(city_rating_config, nil, nil, nil)
    rating_results = build_rating_results_for_city

    ratings_helper = RatingsHelper.new(rating_results,ratings_config)

    #There is a description
    DataDescription.stub(:lookup_table).and_return({[school.state.upcase,"mi_esd_summary"] => "some summary"})

    #Do this to get the display_name.
    #TODO: I could not get factory girl to build this association while constructing the testdatasets due to db sharding.How to solve this?
    TestDataSet.any_instance.stub(:test_data_type).and_return(FactoryGirl.build(:test_data_type, id: 201))

    expect(ratings_helper.construct_city_ratings(school)).to eq({"overall_rating"=>"1",
                                                                                "description"=>"some summary", "city_rating_label"=>"Awesome Test", "rating_breakdowns"=>{"School Climate"=>"1", "Academic Status"=>"1", "Academic Progress"=>"1"}})
  end

  #There is configuration and rating results.But there is no result for overall rating. Hence expect empty city rating.
  it 'should return empty city rating' do
    city_rating_config = JSON.parse('{"rating_breakdowns":{"climate":{"data_type_id": 200,"label": "School Climate"},"status":{"data_type_id":198,"label": "Academic Status"},"progress":{"data_type_id":199,"label":"Academic Progress"}},"overall":{"data_type_id":201,"label": "overall","description_key": "mi_esd_summary","default_methodology_url": "some_url"}}')
    ratings_config = RatingsConfiguration.new(city_rating_config, nil, nil, nil)
    rating_results = build_rating_results_for_city_no_overall  #The rating results do not have an overall rating

    ratings_helper = RatingsHelper.new(rating_results,ratings_config)

    #There is a description
    DataDescription.stub(:lookup_table).and_return({"mi_esd_summary" => "some summary"})

    expect(ratings_helper.construct_city_ratings(school)).to eq({})
  end

  #There is configuration and rating results.But there is no result for overall rating. Hence expect empty city rating.
  it 'should return methodology' do
    city_rating_config = JSON.parse('{"rating_breakdowns":{"climate":{"data_type_id": 200,"label": "School Climate"},"status":{"data_type_id":198,"label": "Academic Status"},"progress":{"data_type_id":199,"label":"Academic Progress"}},"overall":{"data_type_id":201,"label": "overall","description_key": "mi_esd_summary","default_methodology_url": "some_url"}}')
    ratings_config = RatingsConfiguration.new(city_rating_config, nil, nil, nil)
    rating_results = build_rating_results_for_city  #The rating results do not have an overall rating

    ratings_helper = RatingsHelper.new(rating_results,ratings_config)

    #There is a description
    DataDescription.stub(:lookup_table).and_return({[school.state.upcase,"mi_esd_summary"] => "some summary"})

    #Do this to get the display_name.
    #TODO: I could not get factory girl to build this association while constructing the testdatasets due to db sharding.How to solve this?
    TestDataSet.any_instance.stub(:test_data_type).and_return(FactoryGirl.build(:test_data_type, id: 201))

    expect(ratings_helper.construct_city_ratings(school)).to eq({"overall_rating"=>"1","methodology_url" => "some_url",
                                                                 "description"=>"some summary", "city_rating_label"=>"Awesome Test", "rating_breakdowns"=>{"School Climate"=>"1", "Academic Status"=>"1", "Academic Progress"=>"1"}})
  end

  def build_rating_results_for_city
    rating_results = []

    city_rating_data_type_ids = [200,198,199,201]
    city_rating_data_type_ids.each do |data_type_id|
      rating_results += FactoryGirl.build_list(:ratings_test_data_set, 1, data_type_id: data_type_id)
    end

    rating_results
  end

  def build_rating_results_for_city_no_overall
    rating_results = []

    city_rating_data_type_ids = [200,198,199]
    city_rating_data_type_ids.each do |data_type_id|
      rating_results += FactoryGirl.build_list(:ratings_test_data_set, 1, data_type_id: data_type_id)
    end
    rating_results
  end

  #There is a no configuration and no rating results. Hence expect empty preK rating.
  it 'should return empty preK rating' do
    ratings_config = RatingsConfiguration.new(nil, nil, nil, nil)

    ratings_helper = RatingsHelper.new([],ratings_config)

    #There is no description
    DataDescription.stub(:lookup_table).and_return({})

    expect(ratings_helper.construct_preK_ratings(school)).to be_empty
  end

  #There are rating results but there is no configuration. Hence expect empty preK rating.
  it 'should return empty preK rating' do
    ratings_config = RatingsConfiguration.new(nil, nil, nil, nil)
    rating_results = build_rating_results_for_preK

    ratings_helper = RatingsHelper.new(rating_results,ratings_config)

    #There is no description
    DataDescription.stub(:lookup_table).and_return({})

    expect(ratings_helper.construct_preK_ratings(school)).to be_empty
  end

  #There is configuration but there are no rating results. Hence expect empty preK rating.
  it 'should return empty preK rating' do
    prek_rating_config = JSON.parse('{"star_rating":{"data_type_id":217,"description_key":"mi_prek_star_rating_summary"}}')
    ratings_config = RatingsConfiguration.new(nil, nil, nil, prek_rating_config)

    ratings_helper = RatingsHelper.new([],ratings_config)

    #There is no description
    DataDescription.stub(:lookup_table).and_return({})

    expect(ratings_helper.construct_preK_ratings(school)).to be_empty
  end

  #There is configuration and rating results.
  it 'should return star preK rating, description and label' do
    prek_rating_config = JSON.parse('{"star_rating":{"data_type_id":217,"description_key":"mi_prek_star_rating_summary"}}')
    ratings_config = RatingsConfiguration.new(nil, nil, nil, prek_rating_config)
    rating_results = build_rating_results_for_preK

    ratings_helper = RatingsHelper.new(rating_results,ratings_config)

    #Do this to get the display_name.
    #TODO: I could not get factory girl to build this association while constructing the testdatasets due to db sharding.How to solve this?
    TestDataSet.any_instance.stub(:test_data_type).and_return(FactoryGirl.build(:test_data_type, id: 217))

    #There is a description
    DataDescription.stub(:lookup_table).and_return({[school.state.upcase,"mi_prek_star_rating_summary"] => "some summary"})

    expect(ratings_helper.construct_preK_ratings(school)).to eq({"star_rating"=>1, "description"=>"some summary", "preK_rating_label"=>"Awesome Test"})
  end

  def build_rating_results_for_preK
    rating_results = []

    preK_rating_data_type_ids = [217]
    preK_rating_data_type_ids.each do |data_type_id|
      rating_results += FactoryGirl.build_list(:ratings_test_data_set, 1, data_type_id: data_type_id)
    end

    rating_results
  end

  it 'should return empty methodology url' do
    #There is no methodology_url config
    city_rating_config = JSON.parse('{"rating_breakdowns":{"climate":{"data_type_id": 200,"label": "School Climate"},"status":{"data_type_id":198,"label": "Academic Status"},"progress":{"data_type_id":199,"label":"Academic Progress"}},"overall":{"data_type_id":201,"label": "overall","description_key": "mi_esd_summary"}}')
    ratings_config = RatingsConfiguration.new(city_rating_config, nil, nil, nil)

    ratings_helper = RatingsHelper.new({},ratings_config)

    expect(ratings_helper.get_methodology_url(city_rating_config, school)).to be_empty
  end

  it 'should return default methodology url' do
    #There is a default and school specific methodology config. But the school does not have data.Hence default should be used.
    city_rating_config = JSON.parse('{"rating_breakdowns":{"climate":{"data_type_id": 200,"label": "School Climate"},"status":{"data_type_id":198,"label": "Academic Status"},"progress":{"data_type_id":199,"label":"Academic Progress"}},"overall":{"data_type_id":201,"label": "overall","description_key": "mi_esd_summary","default_methodology_url": "default_url","methodology_url_key": "some_key"}}')
    ratings_config = RatingsConfiguration.new(city_rating_config, nil, nil, nil)

    ratings_helper = RatingsHelper.new({},ratings_config)

    expect(ratings_helper.get_methodology_url(city_rating_config, school)).to eq("default_url")
  end

  it 'should return school specific methodology url' do
    city_rating_config = JSON.parse('{"rating_breakdowns":{"climate":{"data_type_id": 200,"label": "School Climate"},"status":{"data_type_id":198,"label": "Academic Status"},"progress":{"data_type_id":199,"label":"Academic Progress"}},"overall":{"data_type_id":201,"label": "overall","description_key": "mi_esd_summary","default_methodology_url": "default_url","methodology_url_key": "some_key"}}')
    ratings_config = RatingsConfiguration.new(city_rating_config, nil, nil, nil)

    ratings_helper = RatingsHelper.new({},ratings_config)
    school.stub(:school_metadata).and_return(Hashie::Mash.new(some_key: "specific_url"))

    expect(ratings_helper.get_methodology_url(city_rating_config, school)).to eq("specific_url")
  end

  def build_rating_results_for_gs
    rating_results = []

    gs_rating_data_type_ids = [164,165,166]
    gs_rating_data_type_ids.each do |data_type_id|
      rating_results += FactoryGirl.build_list(:ratings_test_data_set, 1, data_type_id: data_type_id)
    end

    rating_results
  end

  #There is a no configuration and no rating results. Hence expect empty gs rating.
  it 'should return empty gs rating' do
    ratings_config = RatingsConfiguration.new(nil, nil, nil, nil)

    ratings_helper = RatingsHelper.new([],ratings_config)

    #There is no description
    DataDescription.stub(:lookup_table).and_return({})

    expect(ratings_helper.construct_GS_ratings(school)).to be_empty
  end

  #There are rating results but there is no configuration. Hence expect empty gs rating.
  it 'should return empty gs rating' do
    ratings_config = RatingsConfiguration.new(nil, nil, nil, nil)
    rating_results = build_rating_results_for_gs

    ratings_helper = RatingsHelper.new(rating_results,ratings_config)

    #There is no description
    DataDescription.stub(:lookup_table).and_return({})

    expect(ratings_helper.construct_GS_ratings(school)).to be_empty
  end

  #There is configuration but there are no rating results. Hence expect empty gs rating.
  it 'should return empty gs rating' do
    gs_rating_config = JSON.parse('{"rating_breakdowns":{"test_scores":{"data_type_id":164,"label":"Test score rating"},"progress":{"data_type_id":165,"label":"Student growth rating"},"college_readiness":{"data_type_id":166,"label":"College readiness rating"}},"overall":{"description_key": "what_is_gs_rating_summary"}}')
    ratings_config = RatingsConfiguration.new(nil, nil, gs_rating_config, nil)

    ratings_helper = RatingsHelper.new([],ratings_config)

    #There is no description
    DataDescription.stub(:lookup_table).and_return({})

    expect(ratings_helper.construct_GS_ratings(school)).to be_empty
  end

  #There is configuration and rating results.
  it 'should return overall gs rating, description and label' do
    gs_rating_config = JSON.parse('{"rating_breakdowns":{"test_scores":{"data_type_id":164,"label":"Test score rating"},"progress":{"data_type_id":165,"label":"Student growth rating"},"college_readiness":{"data_type_id":166,"label":"College readiness rating"}},"overall":{"description_key": "what_is_gs_rating_summary"}}')
    ratings_config = RatingsConfiguration.new(nil, nil, gs_rating_config, nil)
    rating_results = build_rating_results_for_gs

    ratings_helper = RatingsHelper.new(rating_results,ratings_config)

    #There is a description
    DataDescription.stub(:lookup_table).and_return({[nil,"what_is_gs_rating_summary"] => "some summary"})

    #Do this to get the display_name.
    #TODO: I could not get factory girl to build this association while constructing the testdatasets due to db sharding.How to solve this?
    TestDataSet.any_instance.stub(:test_data_type).and_return(FactoryGirl.build(:test_data_type, id: 201))

    school.stub(:school_metadata).and_return(school_metadata)
    expect(ratings_helper.construct_GS_ratings(school)).to eq({"overall_rating"=>"1", "description"=>"some summary", "rating_breakdowns"=>{"Test score rating"=>{"rating"=>1}, "Student growth rating"=>{"rating"=>1}, "College readiness rating"=>{"rating"=>1}}})
  end

  #There is configuration and rating results.But there is no result for overall rating. Hence expect empty gs rating.
  it 'should return empty gs rating' do
    gs_rating_config = JSON.parse('{"rating_breakdowns":{"climate":{"data_type_id": 200,"label": "School Climate"},"status":{"data_type_id":198,"label": "Academic Status"},"progress":{"data_type_id":199,"label":"Academic Progress"}},"overall":{"data_type_id":201,"label": "overall","description_key": "mi_esd_summary","default_methodology_url": "some_url"}}')
    ratings_config = RatingsConfiguration.new(nil, nil, gs_rating_config, nil)
    rating_results = build_rating_results_for_gs  #The rating results do not have an overall rating

    ratings_helper = RatingsHelper.new(rating_results,ratings_config)

    #There is a description
    DataDescription.stub(:lookup_table).and_return({"mi_esd_summary" => "some summary"})

    expect(ratings_helper.construct_GS_ratings(school)).to eq({})
  end

  describe '#get_sub_rating_descriptions' do
    before do
      @school = FactoryGirl.build(:school, state: 'mi')
    end

    subject(:ratings_helper) { RatingsHelper.new nil, nil }
    it 'should handle use the footnote even if the description key is blank' do
      description_hash = {
        ['MI', 'blah'] => 'my description'
      }
      ratings_configuration = {
        'description_key' => nil,
        'footnote_key' => 'blah'
      }

      expect(ratings_helper.get_sub_rating_descriptions ratings_configuration, @school, description_hash).to eq 'my description'
    end

    it 'should return the description key description if footnote is nil' do
      description_hash = {
        [nil, 'blah'] => 'my description'
      }
      ratings_configuration = {
        'description_key' => 'blah',
        'footnote_key' => nil
      }

      expect(ratings_helper.get_sub_rating_descriptions ratings_configuration, @school, description_hash).to eq 'my description'
    end
  end

end