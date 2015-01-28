module SubscriptionConcerns
  extend ActiveSupport::Concern

  protected

  def create_subscription(params)

    begin
      school_id = params[:school_id].to_s
      state = params[:state].to_s
      message = params[:message].to_s

      unless current_user.has_subscription?('greatnews')
        current_user.add_subscription!('greatnews')
      end

      if school_id.present? && state.present?
        school_id = school_id.split(/,/)
        state = state.split(/,/)


        if school_id.count != state.count
          raise(ArgumentError, "state and school_id mismatch school_ids count #{school_id.count} with state count #{state.count}")
        end

        school_id.each_with_index {|sch_id, index|
          school = nil

          if sch_id.present? && state[index].present?
            school = School.find_by_state_and_id state[index], sch_id
          end

          if school
            list = school.private_school? ? 'mystat_private' : 'mystat'
          end
          #raise 'Subscription could not be added since a list was not provided.' if list.nil?

          if Subscription.have_available?(list) && !current_user.has_subscription?(list,school)
            current_user.add_subscription!(list, school)
            set_omniture_events_in_cookie(['review_updates_mss_end_event'])
            set_omniture_sprops_in_cookie({'custom_completion_sprop' => 'SignUpForUpdates'})
          end

        }
      end
      if flash.empty?
        message = message.nil? ? "You've signed up to receive updates" : message
        flash_notice message
      end

    rescue => e
      flash_error e.message
    end
  end

end
