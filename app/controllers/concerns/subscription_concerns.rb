module SubscriptionConcerns
  extend ActiveSupport::Concern

  protected

  def create_subscription(params)
    subscription_params = subscription_params(params)
    begin
      subscribe_actions(subscription_params).map do |action|
        subscribed = action.subscribe_to_greatnews
        if subscription_params.has_list?
          subscribed = action.subscribe_to_list(subscription_params.list)
        else
          subscribed = action.subscribe_to_mystat
          set_omniture_events_in_cookie(['review_updates_mss_end_event'])
          set_omniture_sprops_in_cookie({'custom_completion_sprop' => 'SignUpForUpdates'})
        end
      end
      flash_notice(subscription_params.message) if flash.empty?
    rescue => e
      flash_error e.message
    end
  end

  def subscribe_actions(subscription_params)
    # handles zero, one, or multiple schools
    SubscribeAction.for_multiple_schools(
      subscription_params.user,
      subscription_params.states,
      subscription_params.school_ids
    )
  end

  def subscription_params(params)
    SubscriptionParams.new(params) do |obj|
      obj.user = current_user if current_user
    end
  end

  class SubscriptionParams
    attr_accessor :params, :user

    def initialize(params)
      self.params = params
      if block_given?
        yield(self)
      end
    end

    def list
      params[:list]
    end

    def has_list?
      list.present?
    end

    def message
      params[:message].presence || "You've signed up to receive updates"
    end

    def user
      @user || User.find_by_email(params[:email])
    end

    def school_ids
      @_school_ids ||= params[:school_id].to_s.split(',')
    end

    def states
      @_states ||= params[:state].to_s.split(',')
    end

    def subscribe_actions
      # handles zero, one, or multiple schools
      SubscribeAction.for_multiple_schools(user, states.presence, school_ids.presence)
    end
  end

  class SubscribeAction
    attr_accessor :user, :state, :school_id
    # handles zero, one, or multiple states/school IDs
    def self.for_multiple_schools(user, states = [], school_ids = [])
      # If there are no states or school IDs, still create one SubscribeAction
      states << nil if states.empty?
      school_ids << nil if school_ids.empty?
      if school_ids.count != states.count
        raise(ArgumentError,
              "state and school_id mismatch school_ids count #{school_ids.count} with state count #{states.count}"
        )
      end
      states.zip(school_ids).map { |state, school_id| new(user, state, school_id) }
    end

    def initialize(user, state = nil, school_id = nil)
      self.user = user
      self.state = state
      self.school_id = school_id
    end

    def subscribe_to_greatnews
      user.safely_add_subscription!('greatnews', school)
    end

    def subscribe_to_mystat
      return unless school.present?
      list = school.private_school? ? 'mystat_private' : 'mystat'
      user.safely_add_subscription!(list, school)
    end

    def subscribe_to_list(list)
      user.safely_add_subscription!(list, school)
    end

    def school
      @_school ||= begin
        School.find_by_state_and_id(state, school_id) if state.present? && school_id.present?
      end
    end
  end
end
