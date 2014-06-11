require 'spec_helper'

describe RatingsHelper do

  def construct_ratings_configuration(state, hash_of_configs = {})
    hash_of_configs = {
      city_rating: nil,
      state_rating: nil,
      preschool_rating: nil,
      gs_rating: nil,
      pcsb_rating: nil
    }.merge hash_of_configs
    ratings_configuration = RatingsConfiguration.new(hash_of_configs)
  end

  let(:school) { School.new(id: 1, state: 'mi', city: 'Detroit') }
  let(:school_metadata) { Hashie::Mash.new(overallRating: "1")}

  #There is no configuration,and no rating results. Hence expect empty state ratings
  it 'should return empty state ratings' do
    ratings_config = construct_ratings_configuration(school.state)

    ratings_helper = RatingsHelper.new([],ratings_config)

    #There is no description
    allow(DataDescription).to receive(:lookup_table).and_return({})

    expect(ratings_helper.construct_state_rating(school)).to be_empty
  end

  #There are rating results but there is no configuration. Hence expect empty state ratings
  it 'should return empty state ratings' do
    ratings_config = construct_ratings_configuration(school.state)
    rating_results = build_rating_results_for_state

    ratings_helper = RatingsHelper.new(rating_results,ratings_config)

    #There is no description
    allow(DataDescription).to receive(:lookup_table).and_return({})

    expect(ratings_helper.construct_state_rating(school)).to be_empty
  end

  #There is configuration but there are no rating results. Hence expect empty state ratings
  it 'should return empty state ratings' do
    state_rating_config = JSON.parse('{"overall":{"data_type_id":197,"description_key":"mi_state_accountability_summary"}}')
    ratings_config = construct_ratings_configuration(school.state, state_rating: state_rating_config)

    ratings_helper = RatingsHelper.new([],ratings_config)

    #There is no description
    allow(DataDescription).to receive(:lookup_table).and_return({})

    expect(ratings_helper.construct_state_rating(school)).to be_empty
  end

  #There is a configuration and rating results.
  it 'should return overall state rating but no description' do
    state_rating_config = JSON.parse('{"overall":{"data_type_id":197,"description_key":"mi_state_accountability_summary","label":"state rating"}}')

    ratings_config = construct_ratings_configuration(school.state, state_rating: state_rating_config)
    rating_results = build_rating_results_for_state

    ratings_helper = RatingsHelper.new(rating_results,ratings_config)

    #There is no description
    allow(DataDescription).to receive(:lookup_table).and_return({})

    expect(ratings_helper.construct_state_rating(school)).to eq(
      {
        "overall_rating" => "1",
        "description" => nil,
        "label" => "state rating"
      }
    )
  end

  #There is a configuration and rating results.
  it 'should return overall state rating and description' do
    state_rating_config = JSON.parse('{"overall":{"data_type_id":197,"description_key":"mi_state_accountability_summary","label":"state rating"}}')
    ratings_config = construct_ratings_configuration(school.state, state_rating: state_rating_config)
    rating_results = build_rating_results_for_state

    ratings_helper = RatingsHelper.new(rating_results,ratings_config)

    #There is a description
    allow(DataDescription).to receive(:lookup_table).and_return({[school.state.upcase,"mi_state_accountability_summary"] => "some summary"})

    expect(ratings_helper.construct_state_rating(school)).to eq(
      {
        "overall_rating" => "1",
        "description" => "some summary",
        "label" => "state rating"
        }
      )
  end


  #There is configuration and rating results.
  it 'should return overall state rating, breakdown ratings, description and label' do
    state_rating_config = JSON.parse('{"rating_breakdowns":{"standards_met":{"data_type_id": 219,"label": "Standards Met"},"performance index":{"data_type_id":220,"label": "Performance Index"}},"overall":{"data_type_id":201,"label": "Awesome Test","description_key": "mi_state_summary"}}')
    ratings_config = construct_ratings_configuration(school.state, state_rating: state_rating_config)
    rating_results = build_rating_results_for_state_with_breakdowns

    ratings_helper = RatingsHelper.new(rating_results,ratings_config)

    #There is a description
    allow(DataDescription).to receive(:lookup_table).and_return({[school.state.upcase,"mi_state_summary"] => "some summary"})

    expect(ratings_helper.construct_state_rating(school)).to eq(
      {
        "overall_rating" => "1",
        "description" => "some summary",
        "label" => "Awesome Test",
        "rating_breakdowns" => {
          "Performance Index" => {
            "rating" => "1"
          },
          "Standards Met" => {
            "rating" => "1"
          }
        }
      }
    )
  end


  #Using factory girl to build the results and then converting into Json to emulate the school cache table.
  def build_rating_results_for_state
    rating_results = []

    state_rating_data_type_ids = [197]
    state_rating_data_type_ids.each do |data_type_id|
      rating_results += FactoryGirl.build_list(:ratings_test_data_set, 1, data_type_id: data_type_id)
    end

    JSON.parse(rating_results.to_json(:methods => [:school_value_text,:school_value_float]))
  end

  #Using factory girl to build the results and then converting into Json to emulate the school cache table.
  def build_rating_results_for_state_with_breakdowns
    rating_results = []

    state_rating_data_type_ids = [201,219,220]
    state_rating_data_type_ids.each do |data_type_id|
      rating_results += FactoryGirl.build_list(:ratings_test_data_set, 1, data_type_id: data_type_id)
    end
    JSON.parse(rating_results.to_json(:methods => [:school_value_text,:school_value_float]))
  end

  #There is a no configuration and no rating results. Hence expect empty city rating.
  it 'should return empty city rating' do
    ratings_config = construct_ratings_configuration(school.state)

    ratings_helper = RatingsHelper.new([],ratings_config)

    #There is no description
    allow(DataDescription).to receive(:lookup_table).and_return({})

    expect(ratings_helper.construct_city_rating(school)).to be_empty
  end

  #There are rating results but there is no configuration. Hence expect empty city rating.
  it 'should return empty city rating' do
    ratings_config = construct_ratings_configuration(school.state)
    rating_results = build_rating_results_for_city

    ratings_helper = RatingsHelper.new(rating_results,ratings_config)

    #There is no description
    allow(DataDescription).to receive(:lookup_table).and_return({})

    expect(ratings_helper.construct_city_rating(school)).to be_empty
  end

  #There is configuration but there are no rating results. Hence expect empty city rating.
  it 'should return empty city rating' do
    city_rating_config = JSON.parse('{"rating_breakdowns":{"climate":{"data_type_id": 200,"label": "School Climate"},"status":{"data_type_id":198,"label": "Academic Status"},"progress":{"data_type_id":199,"label":"Academic Progress"}},"overall":{"data_type_id":201,"label": "overall","description_key": "mi_esd_summary"}}')
    ratings_config = construct_ratings_configuration(school.state, city_rating: city_rating_config)

    ratings_helper = RatingsHelper.new([],ratings_config)

    #There is no description
    allow(DataDescription).to receive(:lookup_table).and_return({})

    expect(ratings_helper.construct_city_rating(school)).to be_empty
  end

  #There is configuration and rating results.
  it 'should return overall city rating, description and label' do
    city_rating_config = JSON.parse('{"rating_breakdowns":{"climate":{"data_type_id": 200,"label": "School Climate"},"status":{"data_type_id":198,"label": "Academic Status"},"progress":{"data_type_id":199,"label":"Academic Progress"}},"overall":{"data_type_id":201,"label": "Awesome Test","description_key": "mi_esd_summary"}}')
    ratings_config = construct_ratings_configuration(school.state, city_rating: city_rating_config)
    rating_results = build_rating_results_for_city

    ratings_helper = RatingsHelper.new(rating_results,ratings_config)

    #There is a description
    allow(DataDescription).to receive(:lookup_table).and_return({[school.state.upcase,"mi_esd_summary"] => "some summary"})

    expect(ratings_helper.construct_city_rating(school)).to eq(
      {
        "overall_rating" => "1",
        "description" => "some summary",
        "label" => "Awesome Test",
        "rating_breakdowns" => {
          "School Climate" => {
            "rating" => "1",
          },
          "Academic Status" => {
            "rating" => "1"
          },
          "Academic Progress" => {
            "rating" => "1"
          }
        }
      }
    )
  end

  #There is configuration and rating results.But there is no result for overall rating. Hence expect empty city rating.
  it 'should return empty city rating' do
    city_rating_config = JSON.parse('{"rating_breakdowns":{"climate":{"data_type_id": 200,"label": "School Climate"},"status":{"data_type_id":198,"label": "Academic Status"},"progress":{"data_type_id":199,"label":"Academic Progress"}},"overall":{"data_type_id":201,"label": "overall","description_key": "mi_esd_summary","default_methodology_url": "some_url"}}')
    ratings_config = construct_ratings_configuration(school.state, city_rating: city_rating_config)
    rating_results = build_rating_results_for_city_no_overall  #The rating results do not have an overall rating

    ratings_helper = RatingsHelper.new(rating_results,ratings_config)

    #There is a description
    allow(DataDescription).to receive(:lookup_table).and_return({"mi_esd_summary" => "some summary"})

    expect(ratings_helper.construct_city_rating(school)).to eq({})
  end

  #There is configuration and rating results.But there is no result for overall rating. Hence expect empty city rating.
  it 'should return methodology' do
    city_rating_config = JSON.parse('{"rating_breakdowns":{"climate":{"data_type_id": 200,"label": "School Climate"},"status":{"data_type_id":198,"label": "Academic Status"},"progress":{"data_type_id":199,"label":"Academic Progress"}},"overall":{"data_type_id":201,"label": "Awesome Test","description_key": "mi_esd_summary","default_methodology_url": "some_url"}}')
    ratings_config = construct_ratings_configuration(school.state, city_rating: city_rating_config)
    rating_results = build_rating_results_for_city  #The rating results do not have an overall rating

    ratings_helper = RatingsHelper.new(rating_results,ratings_config)

    #There is a description
    allow(DataDescription).to receive(:lookup_table).and_return({[school.state.upcase,"mi_esd_summary"] => "some summary"})

    expect(ratings_helper.construct_city_rating(school)).to eq(
      {
        "overall_rating"=>"1",
        "methodology_url" => "some_url",
        "description"=>"some summary",
        "label"=>"Awesome Test",
        "rating_breakdowns" => {
          "School Climate" => {
            "rating" => "1",
          },
          "Academic Status" => {
            "rating" => "1"
          },
          "Academic Progress" => {
            "rating" => "1"
          }
        }
      }
    )
  end

  #Using factory girl to build the results and then converting into Json to emulate the school cache table.
  def build_rating_results_for_city
    rating_results = []

    city_rating_data_type_ids = [200,198,199,201]
    city_rating_data_type_ids.each do |data_type_id|
      rating_results += FactoryGirl.build_list(:ratings_test_data_set, 1, data_type_id: data_type_id)
    end

    JSON.parse(rating_results.to_json(:methods => [:school_value_text,:school_value_float]))
  end

  #Using factory girl to build the results and then converting into Json to emulate the school cache table.
  def build_rating_results_for_city_no_overall
    rating_results = []

    city_rating_data_type_ids = [200,198,199]
    city_rating_data_type_ids.each do |data_type_id|
      rating_results += FactoryGirl.build_list(:ratings_test_data_set, 1, data_type_id: data_type_id)
    end
    JSON.parse(rating_results.to_json(:methods => [:school_value_text,:school_value_float]))
  end

  #There is a no configuration and no rating results. Hence expect empty preK rating.
  it 'should return empty preK rating' do
    ratings_config = construct_ratings_configuration(school.state)

    ratings_helper = RatingsHelper.new([],ratings_config)

    #There is no description
    allow(DataDescription).to receive(:lookup_table).and_return({})

    expect(ratings_helper.construct_preschool_rating(school)).to be_empty
  end

  #There are rating results but there is no configuration. Hence expect empty preK rating.
  it 'should return empty preK rating' do
    ratings_config = construct_ratings_configuration(school.state)
    rating_results = build_rating_results_for_preK

    ratings_helper = RatingsHelper.new(rating_results,ratings_config)

    #There is no description
    allow(DataDescription).to receive(:lookup_table).and_return({})

    expect(ratings_helper.construct_preschool_rating(school)).to be_empty
  end

  #There is configuration but there are no rating results. Hence expect empty preK rating.
  it 'should return empty preK rating' do
    prek_rating_config = JSON.parse('{"overall":{"data_type_id":217,"description_key":"mi_prek_star_rating_summary"}}')
    ratings_config = construct_ratings_configuration(school.state, preschool_rating: prek_rating_config)

    ratings_helper = RatingsHelper.new([],ratings_config)

    #There is no description
    allow(DataDescription).to receive(:lookup_table).and_return({})

    expect(ratings_helper.construct_preschool_rating(school)).to be_empty
  end

  #There is configuration and rating results.
  it 'should return star preK rating, description and label' do
    prek_rating_config = JSON.parse('{"overall":{"data_type_id":217,"description_key":"mi_prek_star_rating_summary","label":"Awesome Test", "use_school_value_float": "true"}}')
    ratings_config = construct_ratings_configuration(school.state, preschool_rating: prek_rating_config)
    rating_results = build_rating_results_for_preK

    ratings_helper = RatingsHelper.new(rating_results,ratings_config)

    #There is a description
    allow(DataDescription).to receive(:lookup_table).and_return({[school.state.upcase,"mi_prek_star_rating_summary"] => "some summary"})

    expect(ratings_helper.construct_preschool_rating(school)).to eq(
      {
        "overall_rating"=>1,
        "description"=>"some summary",
        "label"=>"Awesome Test"
      }
    )
  end

  #Using factory girl to build the results and then converting into Json to emulate the school cache table.
  def build_rating_results_for_preK
    rating_results = []

    preK_rating_data_type_ids = [217]
    preK_rating_data_type_ids.each do |data_type_id|
      rating_results += FactoryGirl.build_list(:ratings_test_data_set, 1, data_type_id: data_type_id)
    end

    JSON.parse(rating_results.to_json(:methods => [:school_value_text,:school_value_float]))
  end

  it 'should return empty methodology url' do
    #There is no methodology_url config
    city_rating_config = JSON.parse('{"rating_breakdowns":{"climate":{"data_type_id": 200,"label": "School Climate"},"status":{"data_type_id":198,"label": "Academic Status"},"progress":{"data_type_id":199,"label":"Academic Progress"}},"overall":{"data_type_id":201,"label": "overall","description_key": "mi_esd_summary"}}')
    ratings_config = construct_ratings_configuration(school.state, city_rating: city_rating_config)
    rating_configuration = RatingConfiguration.new(school.state, city_rating_config)
    expect(rating_configuration.methodology_url(school)).to be_nil
  end

  it 'should return default methodology url' do
    #There is a default and school specific methodology config. But the school does not have data.Hence default should be used.
    city_rating_config = JSON.parse('{"rating_breakdowns":{"climate":{"data_type_id": 200,"label": "School Climate"},"status":{"data_type_id":198,"label": "Academic Status"},"progress":{"data_type_id":199,"label":"Academic Progress"}},"overall":{"data_type_id":201,"label": "overall","description_key": "mi_esd_summary","default_methodology_url": "default_url","methodology_url_key": "some_key"}}')
    ratings_config = construct_ratings_configuration(school.state, city_rating: city_rating_config)
    rating_configuration = RatingConfiguration.new(school.state, city_rating_config)
    expect(rating_configuration.methodology_url(school)).to eq("default_url")
  end

  it 'should return school specific methodology url' do
    city_rating_config = JSON.parse('{"rating_breakdowns":{"climate":{"data_type_id": 200,"label": "School Climate"},"status":{"data_type_id":198,"label": "Academic Status"},"progress":{"data_type_id":199,"label":"Academic Progress"}},"overall":{"data_type_id":201,"label": "overall","description_key": "mi_esd_summary","default_methodology_url": "default_url","methodology_url_key": "some_key"}}')
    rating_configuration = RatingConfiguration.new(school.state, city_rating_config)
    allow(school).to receive(:school_metadata).and_return(Hashie::Mash.new(some_key: "specific_url"))
    expect(rating_configuration.methodology_url(school)).to eq("specific_url")
  end

  #Using factory girl to build the results and then converting into Json to emulate the school cache table.
  def build_rating_results_for_gs
    rating_results = []

    gs_rating_data_type_ids = [164,165,166]
    gs_rating_data_type_ids.each do |data_type_id|
      rating_results += FactoryGirl.build_list(:ratings_test_data_set, 1, data_type_id: data_type_id)
    end

    JSON.parse(rating_results.to_json(:methods => [:school_value_text,:school_value_float]))
  end

  #There is a no configuration and no rating results. Hence expect empty gs rating.
  it 'should return empty gs rating' do
    ratings_config = construct_ratings_configuration(school.state)

    ratings_helper = RatingsHelper.new([],ratings_config)

    #There is no description
    allow(DataDescription).to receive(:lookup_table).and_return({})

    expect(ratings_helper.construct_gs_rating(school)).to be_empty
  end

  #There are rating results but there is no configuration. Hence expect empty gs rating.
  it 'should return empty gs rating' do
    ratings_config = construct_ratings_configuration(school.state)
    rating_results = build_rating_results_for_gs

    ratings_helper = RatingsHelper.new(rating_results,ratings_config)

    #There is no description
    allow(DataDescription).to receive(:lookup_table).and_return({})

    expect(ratings_helper.construct_gs_rating(school)).to be_empty
  end

  #There is configuration but there are no rating results. Hence expect empty gs rating.
  it 'should return empty gs rating' do
    gs_rating_config = JSON.parse('{"rating_breakdowns":{"test_scores":{"data_type_id":164,"label":"Test score rating"},"progress":{"data_type_id":165,"label":"Student growth rating"},"college_readiness":{"data_type_id":166,"label":"College readiness rating"}},"overall":{"description_key": "what_is_gs_rating_summary"}}')
    ratings_config = construct_ratings_configuration(school.state, gs_rating: gs_rating_config)

    ratings_helper = RatingsHelper.new([],ratings_config)

    #There is no description
    allow(DataDescription).to receive(:lookup_table).and_return({})

    expect(ratings_helper.construct_gs_rating(school)).to be_empty
  end

  #There is configuration and rating results.
  it 'should return overall gs rating, description and label' do
    gs_rating_config = JSON.parse('{"rating_breakdowns":{"test_scores":{"data_type_id":164,"label":"Test score rating"},"progress":{"data_type_id":165,"label":"Student growth rating"},"college_readiness":{"data_type_id":166,"label":"College readiness rating"}},"overall":{"description_key": "what_is_gs_rating_summary", "use_school_value_float": "true"}}')
    ratings_config = construct_ratings_configuration(school.state, gs_rating: gs_rating_config)
    rating_results = build_rating_results_for_gs

    ratings_helper = RatingsHelper.new(rating_results,ratings_config)

    #There is a description
    allow(DataDescription).to receive(:lookup_table).and_return({[nil,"what_is_gs_rating_summary"] => "some summary"})

    allow(school).to receive(:school_metadata).and_return(school_metadata)
    expect(ratings_helper.construct_gs_rating(school)).to eq(
      {
        'overall_rating' => '1',
        'description' => 'some summary',
        'label' => nil,
        'rating_breakdowns' => {
          'Test score rating' => {
            'rating' => 1
          },
          'Student growth rating' => { 
            'rating' => 1
          },
          'College readiness rating' => {
            'rating' => 1
          }
        }
      }
    )
  end

  #There is configuration and rating results.But there is no result for overall rating. Hence expect empty gs rating.
  it 'should return empty gs rating' do
    gs_rating_config = JSON.parse('{"rating_breakdowns":{"climate":{"data_type_id": 200,"label": "School Climate"},"status":{"data_type_id":198,"label": "Academic Status"},"progress":{"data_type_id":199,"label":"Academic Progress"}},"overall":{"data_type_id":201,"label": "overall","description_key": "mi_esd_summary","default_methodology_url": "some_url"}}')
    ratings_config = construct_ratings_configuration(school.state, gs_rating: gs_rating_config)
    rating_results = build_rating_results_for_gs  #The rating results do not have an overall rating

    ratings_helper = RatingsHelper.new(rating_results,ratings_config)

    #There is a description
    allow(DataDescription).to receive(:lookup_table).and_return({"mi_esd_summary" => "some summary"})

    expect(ratings_helper.construct_gs_rating(school)).to eq({})
  end

  describe 'get_sub_rating_descriptions' do
    before do
      @school = FactoryGirl.build(:school, state: 'mi')
    end

    subject(:ratings_helper) { RatingsHelper.new nil, nil }
    it 'should handle use the footnote even if the description key is blank' do
      footnote_hash = {
        ['MI', 'blah'] => 'my description'
      }
      ratings_configuration = {
        'description_key' => nil,
        'footnote_key' => 'blah'
      }

      expect(RatingsHelper.get_sub_rating_descriptions ratings_configuration, @school, footnote_hash).to eq 'my description'
    end

    it 'should return the description key description if footnote is nil' do
      description_hash = {
        [nil, 'blah'] => 'my description'
      }
      ratings_configuration = {
        'description_key' => 'blah',
        'footnote_key' => nil
      }

      expect(RatingsHelper.get_sub_rating_descriptions ratings_configuration, @school, description_hash).to eq 'my description'
    end

    it 'should put a space between description and footnote' do
      description_hash = {
        [nil, 'description'] => 'A description.',
        ['MI', 'footnote'] => 'A footnote.'
      }
      ratings_configuration = {
        'description_key' => 'description',
        'footnote_key' => 'footnote'
      }

      expect(RatingsHelper.get_sub_rating_descriptions ratings_configuration, @school, description_hash).to eq 'A description. A footnote.'
    end
  end

end
