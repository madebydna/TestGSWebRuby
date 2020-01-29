module Exacttarget
  module Builders
    module SubscriptionListDataExtension
      class DataReader

        LIST_TYPES = %w(greatnews osp sponsored)

        def list_signups
          Subscription.where(list: LIST_TYPES).find_each do |signup|
            yield CsvWriter::HEADERS.map {|header| signup[header] }
          end
        end

      end
    end
  end
end