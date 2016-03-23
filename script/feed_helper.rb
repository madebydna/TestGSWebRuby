module FeedHelper
  FEED_CACHE_KEYS = %w(feed_test_scores)

  FEED_NAME_MAPPING = {
      'test_scores' => 'local-gs-test-feed'
  }

  PROFICIENT_AND_ABOVE_BAND = 'proficient and above'

  def all_feeds
    ['test_scores', 'ratings']
  end

  def all_states
    States.abbreviations
  end


  def get_state_fips
    state_fips = {}
    state_fips['AL'] = '01'
    state_fips['AK'] = '02'
    state_fips['AZ'] = '04'
    state_fips['AR'] = '05'
    state_fips['CA'] = '06'
    state_fips['CO'] = '08'
    state_fips['CT'] = '09'
    state_fips['DE'] = '10'
    state_fips['DC'] = '11'
    state_fips['FL'] = '12'
    state_fips['GA'] = '13'
    state_fips['HI'] = '15'
    state_fips['ID'] = '16'
    state_fips['IL'] = '17'
    state_fips['IN'] = '18'
    state_fips['IA'] = '19'
    state_fips['KS'] = '20'
    state_fips['KY'] = '21'
    state_fips['LA'] = '22'
    state_fips['ME'] = '23'
    state_fips['MD'] = '24'
    state_fips['MA'] = '25'
    state_fips['MI'] = '26'
    state_fips['MN'] = '27'
    state_fips['MS'] = '28'
    state_fips['MO'] = '29'
    state_fips['MT'] = '30'
    state_fips['NE'] = '31'
    state_fips['NV'] = '32'
    state_fips['NH'] = '33'
    state_fips['NJ'] = '34'
    state_fips['NM'] = '35'
    state_fips['NY'] = '36'
    state_fips['NC'] = '37'
    state_fips['ND'] = '38'
    state_fips['OH'] = '39'
    state_fips['OK'] = '40'
    state_fips['OR'] = '41'
    state_fips['PA'] = '42'
    state_fips['RI'] = '44'
    state_fips['SC'] = '45'
    state_fips['SD'] = '46'
    state_fips['TN'] = '47'
    state_fips['TX'] = '48'
    state_fips['UT'] = '49'
    state_fips['VT'] = '50'
    state_fips['VA'] = '51'
    state_fips['WA'] = '53'
    state_fips['WV'] = '54'
    state_fips['WI'] = '55'
    state_fips['WY'] = '56'
    return state_fips
  end

  def prep_state_test_infos_data_for_feed
    state_test_infos = []
    state = @state

    TestDescription.where(state: state).find_each do |test|
      data_type_id = test.data_type_id
      test_info = TestDataType.where(:id => data_type_id).first
      test_data_set_info = TestDataSet.on_db(state.downcase.to_sym).
          where(:data_type_id => data_type_id).where(:active => 1).where(:display_target => 'feed').max_by(&:year)
      if test_data_set_info.present?
        state_test_info = {:id => state.upcase + data_type_id.to_s.rjust(5, '0'),
                           :test_id => data_type_id,
                           :test_name => test_info.description,
                           :test_abbrv => test_info.name,
                           :scale => test.scale,
                           :most_recent_year => test_data_set_info.year,
                           :level_code => test_data_set_info.level_code,
                           :description => test.description
        }

      end
      state_test_infos.push(state_test_info)
    end
    state_test_infos
  end

  def prep_school_data_for_feed




  end

  def transpose_school_data_for_feed(schools_decorated_with_cache_results)
    school_data_for_feed = []
    if schools_decorated_with_cache_results.present?
      schools_decorated_with_cache_results.each do |school|
        if @state_test_infos_for_feed.present?
          @state_test_infos_for_feed.each do |test|
            test_id=test[:test_id]
            school_cache = school.school_cache
            all_test_score_data = school_cache.feed_test_scores[test_id.to_s]
            school_data_for_feed = parse_cache_data_for_xml(all_test_score_data, school, test_id, 'school')
          end
        end

      end
    end
    school_data_for_feed
  end

  def get_school_cache_data
    state =@state
    school_ids = @school_ids
    query = SchoolCacheQuery.new.include_cache_keys(FEED_CACHE_KEYS)
    if school_ids.present?
      schools_in_feed = School.on_db(state.downcase.to_sym).where(:id => school_ids)
    else
      schools_in_feed = School.on_db(state.downcase.to_sym).all
    end
    schools_in_feed.each do |school|
      query = query.include_schools(school.state, school.id)
    end
    query_results = query.query
    school_cache_results = SchoolCacheResults.new(FEED_CACHE_KEYS, query_results)
    schools_with_cache_results= school_cache_results.decorate_schools(schools_in_feed)
    schools_decorated_with_cache_results = schools_with_cache_results.map do |school|
      SchoolFeedDecorator.decorate(school)
    end
  end


  def transpose_district_data_for_feed(districts_decorated_with_cache_results)
    districts_data_for_feed = []
    if districts_decorated_with_cache_results.present?
      districts_decorated_with_cache_results.each do |district|
        if @state_test_infos_for_feed.present?
          @state_test_infos_for_feed.each do |test|
            test_id=test[:test_id]
            district_cache = district.district_cache
            all_test_score_data = district_cache.feed_test_scores[test_id.to_s]
            districts_data_for_feed = parse_cache_data_for_xml(all_test_score_data, district, test_id, 'district')
          end
        end

      end
    end
    districts_data_for_feed
  end

  def get_district_cache_data
    state =@state
    ids = @district_ids
    query = DistrictCacheQuery.new.include_cache_keys(FEED_CACHE_KEYS)
    if ids.present?
      districts_in_feed = District.on_db(state.downcase.to_sym).where(:id => ids)
    else
      districts_in_feed = District.on_db(state.downcase.to_sym).all
    end
    districts_in_feed.each do |district|
      query = query.include_districts(district.state, district.id)
    end
    query_results = query.query
    district_cache_results = DistrictCacheResults.new(FEED_CACHE_KEYS, query_results)
    districts_with_cache_results= district_cache_results.decorate_districts(districts_in_feed)
    districts_decorated_with_cache_results = districts_with_cache_results.map do |district|
      DistrictFeedDecorator.decorate(district)
    end
  end

  def prep_state_data_for_feed
    state = @state
    proficiency_bands = Hash[TestProficiencyBand.all.map { |pb| [pb.id, pb] }]
    test_data_subjects = Hash[TestDataSubject.all.map { |o| [o.id, o] }]
    query_results =TestDataSet.test_scores_for_state(state)
    state_level_test_data = []
    query_results.each do |data|
      test_data = {:universal_id => get_state_fips[state.upcase],
                   :entity_level => 'state',
                   :test_id => state.upcase + data.data_type_id.to_s.rjust(5, '0'),
                   :year => data.year,
                   :subject_name => test_data_subjects[data.subject_id].present? ? test_data_subjects[data.subject_id].name : '',
                   :grade_name => data.grade_name,
                   :level_code_name => data.level_code,
                   :score => data.state_value_text|| data.state_value_float,
                   # For proficient and above band id is always null in database
                   :proficiency_band_id => data.proficiency_band_id.nil? ? '' : data.proficiency_band_id,
                   :proficiency_band_name => data.proficiency_band_id.nil? ? PROFICIENT_AND_ABOVE_BAND : proficiency_bands[data.proficiency_band_id].name,
                   :number_tested => data.state_number_tested.nil? ? '' : data.state_number_tested
      }
      state_level_test_data.push(test_data)
    end
    state_level_test_data
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
        feed_name, state, school_id, district_id, location, name= arg.split(':')
        state = state == 'all' ? all_states : state.split(',')
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
      end
      args
    end
  end

  def generate_test_score_feed
    state = @state
    feed_location = @feed_location
    feed_name = @feed_name
    feed_type = @feed_type
    a = Time.now
    puts "--- Start Time for generating feed: FeedType: #{feed_type}  for state #{state} --- #{Time.now}"
    # xsd_schema ='greatschools-test.xsd'

    # Generate District Test Data From Cache
    districts_decorated_with_cache_results = get_district_cache_data


    # Generate District Test Data From Cache
    schools_decorated_with_cache_results = get_school_cache_data



    #Generate State Test Master Data
    @state_test_infos_for_feed = prep_state_test_infos_data_for_feed
    # Generate state Test Data
    state_data_for_feed = prep_state_data_for_feed




    # Translating Cache data to XML for District
    school_data_for_feed =  transpose_school_data_for_feed(schools_decorated_with_cache_results)

    # Translating Cache data to XML for District
    districts_data_for_feed = transpose_district_data_for_feed(districts_decorated_with_cache_results)




    # [:school , :disctrict].each do
    #
    # end
    generated_feed_file_name = feed_name.present? && feed_name != 'default' ? feed_name+"-#{state.upcase}_#{Time.now.strftime("%Y-%m-%d_%H.%M.%S.%L")}.xml" : feed_type+"_#{state}_#{Time.now.strftime("%Y-%m-%d_%H.%M.%S.%L")}.xml"
    generated_feed_file_location = feed_location.present? && feed_location != 'default' ? feed_location : ''

    xmlFile =generated_feed_file_location+generated_feed_file_name


    # Write to XML File
    generate_xml_feed(districts_data_for_feed, school_data_for_feed, state_data_for_feed, @state_test_infos_for_feed, xmlFile)


    # system("xmllint --noout --schema #{xsd_schema} #{xmlFile}")
    puts "--- Time taken to generate feed : FeedType: #{feed_type}  for state #{state} --- #{Time.at((Time.now-a).to_i.abs).utc.strftime "%H:%M:%S:%L"}"

  end

  def generate_xml_feed(districts_data_for_feed, school_data_for_feed, state_data_for_feed, state_test_infos_for_feed, xmlFile)
    File.open(xmlFile, 'w') { |f|
      xml = Builder::XmlMarkup.new(:target => f, :indent => 1)
      xml.instruct! :xml, :version => '1.0', :encoding => 'utf-8'
      xml.tag!('gs-test-feed',
               {'xmlns:xsi' => "http://www.w3.org/2001/XMLSchema-instance",
                :'xsi:noNamespaceSchemaLocation' => "http://www.greatschools.org/feeds/greatschools-test.xsd"}) do
        # Generates test info tag
        generate_xml_tag(state_test_infos_for_feed, 'test', xml)

        # Generate state test data tag
        generate_xml_tag(state_data_for_feed, 'test-result', xml)

        # Generate school test data tag
        generate_xml_tag(school_data_for_feed, 'test-result', xml)

        # Generate district test data tag
        generate_xml_tag(districts_data_for_feed, 'test-result', xml)


      end
    }
  end

  def generate_xml_tag(data, tag_name, xml)
    if data.present?
      data.each do |test_info|
        xml.tag! tag_name do
          test_info.each do |key, value|
            xml.tag! key.to_s.gsub("_", "-"), value
          end
        end
      end
    end
  end

  def parse_cache_data_for_xml(all_test_score_data, entity, test_id, entity_level)
    parsed_data_for_xml = []
    state = @state
    if all_test_score_data.present?
      complete_test_score_data = all_test_score_data["All"]["grades"]
    end
    if complete_test_score_data.present?
      complete_test_score_data.each do |grade, grade_data|
        grade_data_level = grade_data["level_code"]
        grade_data_level.each do |level, subject_data|
          subject_data.each do |subject, years_data|
            years_data.each do |year, data|
              # For proficient and above band id is always null in database
              test_data_for_proficient_and_above = {:universal_id => entity_level == 'district' ? '1' + get_state_fips[state.upcase] + entity.id.to_s.rjust(5, '0') : get_state_fips[state.upcase] + entity.id.to_s.rjust(5, '0'),
                                                    :entity_level => entity_level.titleize,
                                                    :test_id => state.upcase + test_id.to_s.rjust(5, '0'),
                                                    :year => year,
                                                    :subject_name => subject,
                                                    :grade_name => grade,
                                                    :level_code_name => level,
                                                    :score => data["score"],
                                                    :proficiency_band_id => '',
                                                    :proficiency_band_name => PROFICIENT_AND_ABOVE_BAND,
                                                    :number_tested => data["number_students_tested"]
              }
              parsed_data_for_xml.push(test_data_for_proficient_and_above)


              # Get Band Names from Cache
              bands = data.keys.select { |key| key.ends_with?('band_id') }
              band_names = bands.map { |band| band[0..(band.length-"_band_id".length-1)] }
              test_data = {}
              # Get Data For All Bands
              band_names.each do |band|
                test_data = {:universal_id => entity_level == 'district' ? '1' + get_state_fips[state.upcase] + entity.id.to_s.rjust(5, '0') : get_state_fips[state.upcase] + entity.id.to_s.rjust(5, '0'),
                             :entity_level => entity_level.titleize,
                             :test_id => state.upcase + test_id.to_s.rjust(5, '0'),
                             :year => year,
                             :subject_name => subject,
                             :grade_name => grade,
                             :level_code_name => level,
                             :score => data[band+"_score"],
                             # For proficient and above band id is always null in database
                             :proficiency_band_id => data[band+"_band_id"],
                             :proficiency_band_name => band,
                             :number_tested => data[band+"_number_students_tested"]
                }
              end
              parsed_data_for_xml.push(test_data)


            end
          end
        end
      end
    end
    parsed_data_for_xml
  end

  def usage
    abort "\n\nUSAGE: rails runner script/generate_feed_files(all | [feed_name]:[state]:[school_id]:[district_id]:[location]:[name])

Ex: rails runner script/generate_feed_files.rb test_scores:ca:1:1:'/tmp/':test_score_feed (generates test_score file for state of CA , school id 1 , district id 1 at location /tmp/ with name as  <state>_test_score_feed )

Possible feed  files: #{all_feeds.join(', ')}\n\n"
  end
end