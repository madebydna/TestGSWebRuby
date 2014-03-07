module SubscriptionConcerns
  extend ActiveSupport::Concern

  protected

  def create_subscription(params)
    begin
      list = params[:list]
      school_id = params[:school_id]
      state = params[:state]
      message = params[:message]
      if school_id.present? && state.present?
        school = School.on_db(state.downcase.to_sym).find school_id
      else
        school = nil
      end

      raise 'Subscription could not be added since a list was not provided.' if list.nil?

      unless current_user.has_subscription?(list,school)
        current_user.add_subscription!(list, school)
        set_omniture_events_in_session(['review_updates_mss_event'])
        set_omniture_sprops_in_session({'custom_completion_sprop' => 'SignUpForUpdates'})
      end
      flash_notice message if message
    rescue => e
      flash_error e.message
    end
  end

end
