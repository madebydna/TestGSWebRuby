module ExactTargetFileManager
  module Builders
    module SchoolSignupDataExtension
      class DataReader

        LIST_TYPES = %w(mystat mystat_private)

        # Currently (01/20) 12Mil+ records!
        # index on list + state, 2.5min runtime
        # using "select_all", 1m13s
        def school_sign_ups
          States::STATE_HASH.values.uniq.each do |state|
            Subscription.connection.select_all(generate_sql(state).squish).each do |sign_up|
              yield sign_up
            end
          end
        end

        private

        def generate_sql(state)
          <<~SQL
            Select id, school_id, state, member_id, 'en' as language from gs_schooldb.list_active
            where state = '#{state}' and list in (#{quoted_list_types});
          SQL
        end

        def quoted_list_types
          LIST_TYPES.map {|list| "'#{list}'" }.join(",")
        end

      end
    end
  end
end