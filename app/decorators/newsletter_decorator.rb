class NewsletterDecorator < Draper::Decorator

  decorates :subscription
  delegate_all

  def name
    if list=='greatnews'
      'Weekly newsletter'
    elsif Subscription.subscription_product(list)
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
    if list== 'greatnews'
      "The tips and tools you need to make smart choices about your child's education"
    elsif list=='mystat'
      "Track your child's school stats - from test scores to teacher quality."
    elsif list=='sponsor'
      'Receive valuable offers and information from GreatSchools partners.'
    end
  end

end