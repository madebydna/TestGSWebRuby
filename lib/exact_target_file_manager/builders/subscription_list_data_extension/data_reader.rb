module ExactTargetFileManager
  module Builders
    module SubscriptionListDataExtension
      class DataReader

        LIST_TYPES = %w(greatkidsnews greatnews osp sponsor)

        def list_sign_ups
          Subscription.where(list: LIST_TYPES).find_each do |sign_up|
            yield sign_up
          end
        end

      end
    end
  end
end