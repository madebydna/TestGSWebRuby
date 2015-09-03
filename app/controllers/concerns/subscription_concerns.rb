module SubscriptionConcerns
  extend ActiveSupport::Concern

  protected

  def create_subscription(params)
    begin
       
      school_id = params[:school_id].to_s
      state = params[:state].to_s
#     message is nil when not passed to trigger default in set_flash_message method
      message = params[:message]
      list = params[:list].to_s
# by default all users are suscribed to the newsletter including those sent
# directly from specific newsletter link
      subscribe_current_user_to_newsletter

      if subscribe_with_list_specified_and_one_or_no_schools?(list, school_id)
        if school_id.present? && state.present?
          school = School.find_by_state_and_id state, school_id
        else
          school = nil
        end
        subscribe_current_user_to_list(list, school)
      elsif subscribe_with_no_list_specified_and_with_school?(list, school_id, state)
          school_id, state = split_school_parameters(school_id, state)
          raise_mismatch_schools_and_states_error(school_id, state)
          subscribe_current_user_to_schools(school_id, state)
      end

      set_flash_notice(message)
    rescue => e
      flash_error e.message
    end
  end

  def subscribe_current_user_to_newsletter
    unless current_user.has_subscription?('greatnews')
      current_user.add_subscription!('greatnews')
    end
  end

  def subscribe_with_list_specified_and_one_or_no_schools?(list, school_id)
      list.present? && (one_school_id?(school_id) || ! school_id.present?)
  end

  def one_school_id?(school_id)
    school_id.split(',').count == 1
  end

  def subscribe_with_no_list_specified_and_with_school?(list, school_id, state)
    ! list.present? && school_id.present? && state.present?
  end

  def split_school_parameters(school_id, state)
    school_ids = school_id.split(',')
    states = state.split(',')
    return school_ids, states
  end

  def raise_mismatch_schools_and_states_error(school_id, state)
    if school_id.count != state.count
      raise(ArgumentError, 
            "state and school_id mismatch school_ids count #{school_id.count} with state count #{state.count}"
           )
    end
  end

  def subscribe_current_user_to_list(list, school = nil)
    if should_subscribe_user_to_list?(list, school) 
      current_user.add_subscription!(list, school)
    end
  end

  def subscribe_current_user_to_schools(school_id, state)
    school_id.each_with_index do |sch_id, index|
      school = nil

      if sch_id.present? && state[index].present?
        school = School.find_by_state_and_id state[index], sch_id
      end

      if school
        list = school.private_school? ? 'mystat_private' : 'mystat'
      end
      #raise 'Subscription could not be added sisce a list was not provided.' if list.nil?

      if should_subscribe_user_to_list?(list, school)
        current_user.add_subscription!(list, school)
        set_omniture_events_in_cookie(['review_updates_mss_end_event'])
        set_omniture_sprops_in_cookie({'custom_completion_sprop' => 'SignUpForUpdates'})
      end

    end
  end

  def set_flash_notice(message)
      message ||= "You've signed up to receive updates" 
      if flash.empty?
        flash_notice message 
      end
  end

  def should_subscribe_user_to_list?(list, school = nil)
   Subscription.have_available?(list) && !current_user.has_subscription?(list,school)
  end


end
