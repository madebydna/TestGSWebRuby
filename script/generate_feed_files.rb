def all_feeds
  ['test_scores', 'ratings']
end

def all_states
  States.abbreviations
end

def usage
  abort "\n\nUSAGE: rails runner script/generate_feed_files(all | [feed_name]:[state]:[school_id]:[district_id]:[location]:[name])

Ex: rails runner script/generate_feed_files.rb test_scores:ca:1:1:'/tmp/':test_score_feed (generates test_score file for state of CA , school id 1 , district id 1 at location /tmp/ with name as  <state>_test_score_feed )

Possible feed  files: #{all_feeds.join(', ')}\n\n"
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
      require 'pry'
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

parsed_arguments = parse_arguments

usage unless parsed_arguments.present?

def generate_test_score_feed(district_ids, school_ids, state, feed_location, feed_name, feed_type)
  a = Time.now
  puts "--- Start Time for generating feed: FeedType: #{feed_type}  for state #{state} --- #{Time.now}"

  generated_feed_file_name = feed_name.present? && feed_name != 'default' ? feed_name+"_#{state}_#{Time.now.strftime("%Y-%m-%d_%H.%M.%S.%L")}.xml" : feed_type+"_#{state}_#{Time.now.strftime("%Y-%m-%d_%H.%M.%S.%L")}.xml"
  generated_feed_file_location = feed_location.present? && feed_location != 'default' ? feed_location : ''

  File.open(generated_feed_file_location+generated_feed_file_name, 'w') { |f|
    xml = Builder::XmlMarkup.new(:target => f, :indent => 1)
    if school_ids.present?
      School.on_db(state.downcase.to_sym).where(:id => school_ids).each do |school|
        xml.school {
          xml.school_id school.id
        }
      end
    else
      School.on_db(state.downcase.to_sym).all.each do |school|
        xml.school {
          xml.school_id school.id
        }
      end
    end
    if district_ids.present?
      District.on_db(state.downcase.to_sym).where(:id => district_ids).each do |district|
        xml.district {
          xml.district_id district.id
        }
      end
    else
      District.on_db(state.downcase.to_sym).all.each do |district|
        xml.district {
          xml.district_id district.id
        }
      end
    end
  }

  puts "--- Time taken to generate feed : FeedType: #{feed_type}  for state #{state} --- #{Time.at((Time.now-a).to_i.abs).utc.strftime "%H:%M:%S:%L"}"

end

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
        feed_location = location.present? && location[index].present? ? location[index] : 'default'
        feed_name = name.present? && name[index].present? ? name[index] : 'default'
        generate_test_score_feed(district_ids, school_ids, state, feed_location, feed_name, feed)
      end
    end
  end
end


