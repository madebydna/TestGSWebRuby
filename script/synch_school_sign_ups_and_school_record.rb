require 'csv'
require 'ostruct'

class Hash
  def to_openstruct
    JSON.parse to_json, object_class: OpenStruct
  end
end

class SynchSchoolSignUpsAndSchoolRecord

  LIST_TYPES = %w(mystat mystat_private)
  HEADERS = %w(id member_id state school_id list language)
  FILE_PATH = "/tmp/mss_to_dead_schools.csv"

  def quoted_list_types
    LIST_TYPES.map { |list| "'#{list}'" }.join(",")
  end

  def generate_sql(state)
    <<~SQL
      Select * from gs_schooldb.list_active
      where state = '#{state}' and list in (#{quoted_list_types});
    SQL
  end

  def insert_into_history(hash)
    SubscriptionHistory.archive_subscription(hash.to_openstruct)
  end

  def delete_from_list(id)
    Subscription.delete(id)
  end

  def run
    States::STATE_HASH.values.uniq.each do |state|
      Subscription.connection.select_all(generate_sql(state).squish).each do |sign_up|
        results = School.on_db(state.downcase.to_sym).find_by_id(sign_up['school_id'])&.active
        if (results != 1)
          insert_into_history(sign_up)
          delete_from_list(sign_up['id'])
        end
      end
    end
  end
end

SynchSchoolSignUpsAndSchoolRecord.new.run