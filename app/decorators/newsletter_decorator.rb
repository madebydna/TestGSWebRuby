class NewsletterDecorator < Draper::Decorator

  decorates :subscription
  delegate_all

  def name
    if Subscription.subscription_product(list)
       Subscription.subscription_product(list).long_name
    else
        list.to_s
    end
  end

  def school
    if school_id.present? && state.present?
      School.find_by_state_and_id(state, school_id)
    end
  end

  def description
    Subscription.subscription_product(list) && Subscription.subscription_product(list).description || ''
  end

end