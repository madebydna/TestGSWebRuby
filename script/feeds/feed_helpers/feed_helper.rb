require_relative '../../feeds/feed_config/feed_constants'
require_relative 'feed_data_helper'


module FeedHelper

  include Rails.application.routes.url_helpers
  include UrlHelper
  include FeedConstants

  # This method is needed to Use URLHelper to generate School and District Url
  def default_url_options
    hash = {}
    # the feed Url need to have production host values irrespective of the server the feeds are being running on hence the value is set here
    hash[:host] = 'www.greatschools.org'
    hash[:port]= nil
    return hash
  end

  def options_for_generating_all_feeds
    [{  states: all_states, feed_names: all_feeds}]
  end

  def parse_arguments
    # To Generate All feeds for all states in current directory do rails runner script/feeds/feed_scripts/generate_feed_files.rb all
    if ARGV[0] == 'all' && ARGV[1].nil?
      OPTIONS_FOR_GENERATING_ALL_FEEDS
    else
      feed_name, state, school_id, district_id, location, name, batch_size= ARGV[0].try(:split, ':')
      state = state == 'all' ? all_states : split_argument(state)
      feed_name = feed_name == 'all' ? all_feeds : split_argument(feed_name)
      return false unless (feed_name-all_feeds).empty?
      return false unless (state-all_states).empty?
      args = {
          :states => state,
          :feed_names => feed_name,
          :school_id => split_argument(school_id),
          :district_id => split_argument(district_id),
          :location => split_argument(location),
          :name => split_argument(name),
          :batch_size => batch_size
      }
    end
  end

  def split_argument(argument)
    argument.try(:split, ",") || argument
  end

  def get_feed_name(feed, index)
    feed_location = @location.present? && @location[index].present?  ? @location[index] : ''
    feed_name = @name.present? && @name[index].present? ? @name[index] : FEED_NAME_MAPPING[feed]
    generated_feed_file_name = feed_name.present? ? feed_name+"-#{@state.upcase}_#{Time.now.strftime("%Y-%m-%d_%H.%M.%S.%L")}.xml" : feed+"_#{@state}_#{Time.now.strftime("%Y-%m-%d_%H.%M.%S.%L")}.xml"
    xml_name =feed_location+generated_feed_file_name
  end

  def usage
    abort "\n\nUSAGE: rails runner script/generate_feed_files(all | [feed_name]:[state]:[school_id]:[district_id]:[location]:[name]:[batch-size])

    Ex: rails runner script/generate_feed_files.rb test_scores:ca:1,2:1,2:'/tmp/':test_score_feed_test:5 (generates test_score file for state of CA , school id 1,2 , district id 1,2 at location /tmp/ with name as  <state>_test_score_feed batching 5 schools at a time)

    Possible feed  files: #{all_feeds.join(', ')}\n\n"
  end

  def transpose_ratings_description(data_type_id)
    # How we calculate test_description  can change based on decision from Product team
    if data_type_id == RATINGS_ID_RATING_FEED_MAPPING['official_overall']
      desc =  "The GreatSchools rating is a simple tool for parents to compare schools based on test scores, student academic
                   growth, and college readiness. It compares schools across the state, where the highest rated schools in
                   the state are designated as 'Above Average' and the lowest 'Below Average'  It is designed to be a starting
                   point to help parents make baseline comparisons. We always advise parents to visit the school and consider other
                   information on school performance and programs, as well as consider their child's and family's needs as part of
                   the school selection process."
    elsif data_type_id == RATINGS_ID_RATING_FEED_MAPPING['test_rating']
      desc = "GreatSchools compared the test results for each grade and subject across all
                       #{@state} schools and divided them into 1 through 10 ratings (10 is the best).
                       Please note, private schools are not required to release test results, so ratings are available
                       only for public schools. GreatSchools Ratings cannot be compared across states,
                       because of differences in the states' standardized testing programs.
                       Keep in mind that when comparing schools using GreatSchools Ratings it's important to factor in
                       other information, including the quality of each school's teachers, the school culture, special programs, etc."
    end

  end

  def transpose_number_tested(data)
    data["number_students_tested"].nil? ? '' : data["number_students_tested"]
  end

  def transpose_test_id(test_id)
    state = @state
    state.upcase + test_id.to_s.rjust(5, '0')
  end

  def transpose_breakdown_id(breakdown_id,breakdown_name,test_data_breakdowns)
   breakdown_name = breakdown_name == 'All' ? 'All students' : breakdown_name
   breakdown_id.present?  ?  breakdown_id : test_data_breakdowns[breakdown_name].try(:id)

  end

  def transpose_url(entity,entity_level)
    begin
      if (entity_level == ENTITY_TYPE_DISTRICT)
        url = city_district_url district_params_from_district(entity)
      elsif (entity_level == ENTITY_TYPE_SCHOOL)
        url = school_url entity
      end
    rescue  => e
      puts "#{e}"
      url = state_url(state_params(@state))
    end
  end

  def transpose_test_score(band, data,entity_level)
    if (entity_level == ENTITY_TYPE_STATE)
      data.state_value_text|| data.state_value_float
    else
      band == PROFICIENT_AND_ABOVE_BAND ?  data["score"]: data[band+"_score"]
    end
  end

  def transpose_ratings(data,entity_level)
    if (entity_level == ENTITY_TYPE_SCHOOL)
      rating = data["school_value_text"]|| data["school_value_float"]
    elsif (entity_level == ENTITY_TYPE_DISTRICT)
      rating = data["value_text"]|| data["value_float"]
    end
    # Rating should be sent nil and not zero if data not present , that's why the try
    rating.try(:to_i)
  end

  def transpose_band_name(band)
    # For proficient and above band id is always null in database
    band == nil ? PROFICIENT_AND_ABOVE_BAND:  band
  end

  def transpose_band_id(band, data, entity_level)
    # For proficient and above band id is always null in database
    if (entity_level == ENTITY_TYPE_STATE )
      band ==  data["proficiency_band_id"].nil? ? '' : data["proficiency_band_id"]
    else
      band == PROFICIENT_AND_ABOVE_BAND ? '' : data[band+"_band_id"]
    end
  end

  def transpose_universal_id(entity = nil, entity_level)
    state = @state
    if (entity_level == ENTITY_TYPE_DISTRICT)
      '1' + state_fips[state.upcase] + entity.id.to_s.rjust(5, '0')
    elsif (entity_level == ENTITY_TYPE_SCHOOL)
      state_fips[state.upcase] + entity.id.to_s.rjust(5, '0')
    else
      state_fips[state.upcase]
    end

  end



  def write_xml_tag(data, tag_name, xml)
    if data.present?
      data_for_xml = data.reject(&:blank?)
      data_for_xml.each do |tag_data|
        xml.tag! tag_name do
          tag_data.each do |key, value|
            xml.tag! key.to_s.gsub("_", "-"), value
          end
        end
      end
    end
  end

end