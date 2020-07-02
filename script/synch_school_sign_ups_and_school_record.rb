require 'csv'

class SynchSchoolSignUpsAndSchoolRecord

  LIST_TYPES = %w(mystat mystat_private)
  HEADERS = %w(id member_id state school_id list language)
  FILE_PATH = "/tmp/mss_to_dead_schools.csv"
  # Currently (01/20) 12Mil+ records!
  # index on list + state, 2.5min runtime
  # using "select_all", 1m13s

  def quoted_list_types
    LIST_TYPES.map { |list| "'#{list}'" }.join(",")
  end

  def generate_sql(state)
    <<~SQL
      Select id, school_id, state, list, member_id, language from gs_schooldb.list_active
      where state = '#{state}' and list in (#{quoted_list_types});
    SQL
  end

  def run
    CSV.open(FILE_PATH, 'w') do |csv|
      csv << HEADERS
    end
    States::STATE_HASH.values.uniq.each do |state|
      puts("state = #{state}")
      count = 0
      Subscription.connection.select_all(generate_sql(state).squish).each do |sign_up|
        results = School.on_db(state.downcase.to_sym).find_by_id(sign_up['school_id'])&.active
        if (results != 1)
          count += 1
          CSV.open(FILE_PATH, 'a') do |csv|
            csv << HEADERS.map { |header| sign_up[header] }
          end
          # puts "member_id = #{sign_up['member_id']} - state = #{sign_up['state']} - school_id = #{sign_up['school_id']} - id = #{sign_up['id']} - list = #{sign_up['list']}"
        end
      end
      puts("count = #{count}")
    end
  end
end

SynchSchoolSignUpsAndSchoolRecord.new.run