module Exacttarget
  module SubscriptionListDataExtension
    class DataReader

      LIST_TYPES = %w(greatnews osp sponsored)

      def list_signups
        States::STATE_HASH.values.each do |state|
          Subscription.connection.select_all(generate_sql(state).squish).each do |signup|
            yield CsvWriter::HEADERS.map {|header| signup[header] }
          end
        end
      end


      private

      def generate_sql(state)
        <<~SQL
          Select id, member_id, list, 'en' as language from gs_schooldb.list_active
          where state = '#{state}' and list in (#{quoted_list_types});
        SQL
      end

      def quoted_list_types
        LIST_TYPES.map {|list| "'#{list}'" }.join(",")
      end

    end
  end
end