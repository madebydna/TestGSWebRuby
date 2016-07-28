class UserSubscriptions

  def initialize(user)
    @user = user
  end

  def get
    subscriptions = []

    if @user.subscriptions.present?

      if @user.has_signedup?('greatnews')
        subscriptions << :greatnews
      end

      if @user.has_signedup?('greatkidsnews')
        subscriptions << :greatkidsnews
      end

      if @user.has_signedup?('sponsor')
        subscriptions << :sponsor
      end

    end

    subscriptions
  end
end

############################################################################################################
#
#   This next section represents the flow and information needed for the accounts view
#   This will be refactored in the next round
#
############################################################################################################

#     @current_user.subscriptions.group_by(&:list).each do |list, subscriptions|
#       if Subscription.is_grouped?(list)
#         first_decorated_subscription = NewsletterDecorator.decorate(subscriptions.first)
#         # print first_decorated_subscription.description
#         subscriptions.each do |subscription|
#           decorated_subscription = NewsletterDecorator.decorate(subscription)
#           # print subscription.id
#           if decorated_subscription.school && decorated_subscription.school.city && decorated_subscription.school.state
#             #   print subscription.id and subscription.list
#             # print decorated_subscription.school.name, decorated_subscription.school.city
#             # print decorated_subscription.school.state
#           end
#         end
#       else
#         decorated_subscription = NewsletterDecorator.decorate(subscriptions.first)
#         # print subscriptions.first.id
#         # print subscriptions.first.list
#         # print subscriptions.first.id
#         # print decorated_subscription.name
#         # print decorated_subscription.description
#       end
#       if !current_user.has_signedup?('greatnews')
#         # set checkbox for greatnews
#         # print Subscription.subscription_product("greatnews").long_name
#         # print Subscription.subscription_product("greatnews").description
#       end
#       if !current_user.has_signedup?('sponsor')
#         # set checkbox for sponsor
#         # print Subscription.subscription_product("sponsor").long_name
#         # print Subscription.subscription_product("sponsor").description
#       end
#       if !current_user.has_signedup?('mystat') && !current_user.has_signedup?('mystat_private') && !current_user.has_signedup?('mystat_unverified')
#         # print some content
#       end
#     end
#   else
#     # set checkbox for greatnews
#     # print Subscription.subscription_product("greatnews").long_name
#     # print Subscription.subscription_product("greatnews").description
#     # set checkbox for sponsor
#     # print Subscription.subscription_product("sponsor").long_name
#     # print Subscription.subscription_product("sponsor").description
#     # print some content
#   end


