require_relative '../../feeds/feed_config/feed_constants'


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

  def get_feed_name(feed, index)
    feed_location = @location.present? && @location[index].present?  ? @location[index] : ''
    feed_name = @name.present? && @name[index].present? ? @name[index] : FEED_NAME_MAPPING[feed]
    generated_feed_file_name = feed_name.present? ? feed_name+"-#{@state.upcase}_#{Time.now.strftime("%Y-%m-%d_%H.%M.%S.%L")}.xml" : feed+"_#{@state}_#{Time.now.strftime("%Y-%m-%d_%H.%M.%S.%L")}.xml"
    xml_name =feed_location+generated_feed_file_name

  end

  def get_school_batches
    state =@state
    school_ids = @school_ids
    if school_ids.present?
      schools_in_feed = School.on_db(state.downcase.to_sym).where(:id => school_ids)
    else
      schools_in_feed = School.on_db(state.downcase.to_sym).all
    end
    school_batches = []
    schools_in_feed.each_slice(@batch_size.to_i) do |slice|
      school_batches.push(slice)
    end
    puts "Total Schools in State #{schools_in_feed.size}"
    puts "School Batch Size #{@batch_size}"
    puts "Total Schools Batches Feed #{school_batches.size}"
    school_batches
  end


  def get_district_batches
    state =@state
    district_ids = @district_ids
    if district_ids.present?
      districts_in_feed = District.on_db(state.downcase.to_sym).where(:id => district_ids)
    else
      districts_in_feed = District.on_db(state.downcase.to_sym).all
    end
    district_batches = []
    districts_in_feed.each_slice(@batch_size.to_i) do |slice|
      district_batches.push(slice)
    end
    puts "Total Districts in State #{districts_in_feed.size}"
    puts "District Batch Size #{@batch_size}"
    puts "Total Districts Batches Feed #{district_batches.size}"
    district_batches
  end

  def get_schools_batch_cache_data(school_batch)
    query = SchoolCacheQuery.new.include_cache_keys(FEED_CACHE_KEYS)
    school_batch.each do |school|
      query = query.include_schools(school.state, school.id)
    end
    query_results = query.query_and_use_cache_keys
    school_cache_results = SchoolCacheResults.new(FEED_CACHE_KEYS, query_results)
    schools_with_cache_results= school_cache_results.decorate_schools(school_batch)
    schools_decorated_with_cache_results = schools_with_cache_results.map do |school|
      SchoolFeedDecorator.decorate(school)
    end
  end

  def get_districts_batch_cache_data(district_batch)
    query = DistrictCacheQuery.new.include_cache_keys(FEED_CACHE_KEYS)
    district_batch.each do |district|
      query = query.include_districts(district.state, district.id)
    end
    query_results = query.query_and_use_cache_keys
    district_cache_results = DistrictCacheResults.new(FEED_CACHE_KEYS, query_results)
    districts_with_cache_results= district_cache_results.decorate_districts(district_batch)
    districts_decorated_with_cache_results = districts_with_cache_results.map do |district|
      DistrictFeedDecorator.decorate(district)
    end
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


  def parse_arguments
    # Returns false or parsed arguments
    if ARGV[0] == 'all' && ARGV[1].nil?
      [{
           states: all_states,
           feed_name: all_feeds
       }]
    else
      args = []
      ARGV.each_with_index do |arg, i|
        feed_name, state, school_id, district_id, location, name, batch_size= arg.split(':')
        state = state == 'all' ? all_states : state.split(',')
        batch_size = batch_size if batch_size.present?
        return false unless (state-all_states).empty?
        feed_name ||= 'none_given'
        feed_name = feed_name.split(',')
        feed_name = all_feeds if feed_name == ['all']
        return false unless (feed_name-all_feeds).empty?

        school_id = school_id.present? ? school_id.split(',') : school_id
        district_id = district_id.present? ? district_id.split(',') : district_id
        location = location.present? ? location.split(',') : location
        name = name.present? ? name.split(',') : name

        args[i] = {}
        args[i][:states] = state
        args[i][:feed_names] = feed_name
        args[i][:school_id] = school_id if school_id.present?
        args[i][:district_id] = district_id if district_id.present?
        args[i][:location] = location if location.present?
        args[i][:name] = name if name.present?
        args[i][:batch_size] = batch_size if batch_size.present?

      end
      args
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
      data["school_value_text"]|| data["school_value_float"]
    elsif (entity_level == ENTITY_TYPE_DISTRICT)
      data["value_text"]|| data["value_float"]
    end
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

  def usage
    abort "\n\nUSAGE: rails runner script/generate_feed_files(all | [feed_name]:[state]:[school_id]:[district_id]:[location]:[name]:[batch-size])

    Ex: rails runner script/generate_feed_files.rb test_scores:ca:1,2:1,2:'/tmp/':test_score_feed_test:5 (generates test_score file for state of CA , school id 1,2 , district id 1,2 at location /tmp/ with name as  <state>_test_score_feed batching 5 schools at a time)

    Possible feed  files: #{all_feeds.join(', ')}\n\n"
  end

end