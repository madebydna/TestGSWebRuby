module GenerateFeed
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

  def generate_state_test_info(state)
    state_test_infos = []

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

  def prep_school_data_for_feed(school_ids, state)
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
      FeedDecorator.decorate(school)
    end
  end

  def prep_district_data_for_feed(district_ids, state)
    query = DistrictCacheQuery.new.include_cache_keys(FEED_CACHE_KEYS)
    if district_ids.present?
      districts_in_feed = District.on_db(state.downcase.to_sym).where(:id => district_ids)
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
end


include GenerateFeed
FEED_CACHE_KEYS = %w(feed_test_scores)


def usage
  abort "\n\nUSAGE: rails runner script/generate_feed_files(all | [feed_name]:[state]:[school_id]:[district_id]:[location]:[name])

Ex: rails runner script/generate_feed_files.rb test_scores:ca:1:1:'/tmp/':test_score_feed (generates test_score file for state of CA , school id 1 , district id 1 at location /tmp/ with name as  <state>_test_score_feed )

Possible feed  files: #{all_feeds.join(', ')}\n\n"
end


def generate_test_score_feed(district_ids, school_ids, state, feed_location, feed_name, feed_type)
  a = Time.now
  puts "--- Start Time for generating feed: FeedType: #{feed_type}  for state #{state} --- #{Time.now}"
  # xsd_schema ='greatschools-test.xsd'
  state_test_infos = generate_state_test_info(state)
  generated_feed_file_name = feed_name.present? && feed_name != 'default' ? feed_name+"_#{state}_#{Time.now.strftime("%Y-%m-%d_%H.%M.%S.%L")}.xml" : feed_type+"_#{state}_#{Time.now.strftime("%Y-%m-%d_%H.%M.%S.%L")}.xml"
  generated_feed_file_location = feed_location.present? && feed_location != 'default' ? feed_location : ''
  xmlFile =generated_feed_file_location+generated_feed_file_name
  File.open(xmlFile, 'w') { |f|
    xml = Builder::XmlMarkup.new(:target => f, :indent => 1)
    xml.instruct! :xml, :version => '1.0', :encoding => 'utf-8'
    xml.tag!('gs-test-feed',
             {'xmlns:xsi' => "http://www.w3.org/2001/XMLSchema-instance",
              :'xsi:noNamespaceSchemaLocation' => "http://www.greatschools.org/feeds/greatschools-test.xsd"}) do
      if state_test_infos.present?
        state_test_infos.each do |test|
          if test.present?
            xml.tag! 'test' do
              xml.tag! 'id', test[:id]
              xml.tag! 'test-name', test[:test_name]
              xml.tag! 'scale', test[:scale]
              xml.tag! 'test-abbrv', test[:test_abbrv]
              xml.tag! 'most-recent-year', test[:most_recent_year]
              xml.tag! 'level-code', test[:level_code]
              xml.tag! 'description', test[:description]
            end
          end
        end
      end
      # entity_type = "district"
      # require 'pry'
      #      binding.pry
      school_data_for_feed = prep_school_data_for_feed(school_ids, state)
      cached_data_for_all_districts = prep_district_data_for_feed(district_ids, state)

      if school_data_for_feed.present?
        school_data_for_feed.each do |school|
          if state_test_infos.present?
            state_test_infos.each do |test|
              test_id=test[:test_id]
              complete_test_score_data = school.school_cache.feed_test_scores[test_id.to_s]["All"]["grades"]
              complete_test_score_data.each do |grade, grade_data|
                grade_data_level = grade_data["level_code"]
                grade_data_level.each do |level, subject_data|
                  subject_data.each do |subject, years_data|
                    years_data.each do |year, data|
                      # Proficient and above data that is not stored by band name in cache data
                      xml.tag! 'test-result' do
                        xml.tag! 'universal-id', get_state_fips[state.upcase] + school.id.to_s.rjust(5, '0')
                        xml.tag! 'entity-level', "School"
                        xml.tag! 'test-id', state.upcase + test_id.to_s.to_s.rjust(5, '0')
                        xml.tag! 'grade-name', grade
                        xml.tag! 'level-code-name', level
                        xml.tag! 'subject-name', subject
                        xml.tag! 'year', year
                        xml.tag! 'number-tested', data["number_students_tested"]
                        xml.tag! 'score', data["score"]
                        xml.tag! 'proficiency-band-name', "Proficient and above"
                      end

                      bands = data.keys.select { |key| key.ends_with?('band_id') }
                      band_names = bands.map { |band| band[0..(band.length-"_band_id".length-1)] }
                      band_names.each do |band|
                        xml.tag! 'test-result' do
                          xml.tag! 'universal-id', get_state_fips[state.upcase] + school.id.to_s.rjust(5, '0')
                          xml.tag! 'entity-level', "School"
                          xml.tag! 'test-id', state.upcase + test_id.to_s.to_s.rjust(5, '0')
                          xml.tag! 'grade-name', grade
                          xml.tag! 'level-code-name', level
                          xml.tag! 'subject-name', subject
                          xml.tag! 'year', year
                          xml.tag! 'number-tested', data[band+"_number_students_tested"]
                          xml.tag! 'score', data[band+"_score"]
                          xml.tag! 'proficiency-band-name', band
                          xml.tag! 'proficiency-band-id', data[band+"_band_id"]
                        end
                      end

                    end
                  end
                end
              end

            end

          end

        end
      end
      if cached_data_for_all_districts.present?
        cached_data_for_all_districts.each do |district|
          if state_test_infos.present?
            state_test_infos.each do |test|
              test_id=test[:test_id]
              complete_test_score_data = district.district_cache.feed_test_scores[test_id.to_s]["All"]["grades"]
              complete_test_score_data.each do |grade, grade_data|
                grade_data_level = grade_data["level_code"]
                grade_data_level.each do |level, subject_data|
                  subject_data.each do |subject, years_data|
                    years_data.each do |year, data|
                      # Proficient and above data that is not stored by band name in cache data
                      xml.tag! 'test-result' do
                        xml.tag! 'universal-id', get_state_fips[state.upcase] + district.id.to_s.rjust(5, '0')
                        xml.tag! 'entity-level', "District"
                        xml.tag! 'test-id', state.upcase + test_id.to_s.to_s.rjust(5, '0')
                        xml.tag! 'grade-name', grade
                        xml.tag! 'level-code-name', level
                        xml.tag! 'subject-name', subject
                        xml.tag! 'year', year
                        xml.tag! 'number-tested', data["number_students_tested"]
                        xml.tag! 'score', data["score"]
                        xml.tag! 'proficiency-band-name', "proficient and above"
                      end

                      bands = data.keys.select { |key| key.ends_with?('band_id') }
                      band_names = bands.map { |band| band[0..(band.length-"_band_id".length-1)] }
                      band_names.each do |band|
                        xml.tag! 'test-result' do
                          xml.tag! 'universal-id', get_state_fips[state.upcase] + district.id.to_s.rjust(5, '0')
                          xml.tag! 'entity-level', "District"
                          xml.tag! 'test-id', state.upcase + test_id.to_s.to_s.rjust(5, '0')
                          xml.tag! 'grade-name', grade
                          xml.tag! 'level-code-name', level
                          xml.tag! 'subject-name', subject
                          xml.tag! 'year', year
                          xml.tag! 'number-tested', data[band+"_number_students_tested"]
                          xml.tag! 'score', data[band+"_score"]
                          xml.tag! 'proficiency-band-name', band
                          xml.tag! 'proficiency-band-id', data[band+"_band_id"]
                        end
                      end

                    end
                  end
                end
              end

            end

          end

        end
      end

      # if district_ids.present?
      #   District.on_db(state.downcase.to_sym).where(:id => district_ids).each do |district|
      #     xml.district {
      #       xml.district_id district.id
      #     }
      #   end
      # else
      #   District.on_db(state.downcase.to_sym).all.each do |district|
      #     xml.district {
      #       xml.district_id district.id
      #     }
      #   end
      # end
    end
  }


  # system("xmllint --noout --schema #{xsd_schema} #{xmlFile}")
  puts "--- Time taken to generate feed : FeedType: #{feed_type}  for state #{state} --- #{Time.at((Time.now-a).to_i.abs).utc.strftime "%H:%M:%S:%L"}"

end

parsed_arguments = parse_arguments

usage unless parsed_arguments.present?


parsed_arguments.each do |args|
  states = args[:states]
  feed_names = args[:feed_names]
  school_ids = args[:school_id]
  district_ids = args[:district_id]
  location = args[:location]
  name = args[:name]
  feed_names.each_with_index do |feed, index|
    states.each do |state|
      if feed == 'test_scores'
        feed_location = location.present? && location[index].present? ? location[index] : 'default'
        feed_name = name.present? && name[index].present? ? name[index] : 'default'
        generate_test_score_feed(district_ids, school_ids, state, feed_location, feed_name, feed)
      elsif feed == 'ratings'
        # To do Create the feed for ratings
           end
    end
  end
end



