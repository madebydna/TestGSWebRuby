module DeferredActionConcerns
  extend ActiveSupport::Concern
  include ReviewControllerConcerns
  include SubscriptionConcerns
  include FavoriteSchoolsConcerns
  protected

  ALLOWED_DEFERRED_ACTIONS = %w(
    create_subscription_deferred
    save_review_deferred
    add_favorite_school_deferred
    report_review_deferred
    saved_search_deferred
  )

  def save_deferred_action(action, params)
    write_cookie_value :deferred_action, [action, params]
  end

  def get_deferred_action
    read_cookie_value :deferred_action
  end

  def executed_deferred_action
    action, params = get_deferred_action

    if ALLOWED_DEFERRED_ACTIONS.include?(action)
      if action.present? && self.respond_to?(action, true) && ALLOWED_DEFERRED_ACTIONS.include?(action)
        begin
          Rails.logger.debug("Executing deferred action: #{action}")
          success = self.send action, params
          cookies.delete(:deferred_action, domain: :all) if success
        rescue => error
          Rails.logger.debug "Error when executing deferred action: #{action} on #{self.class}. " +
                               "Deleting cookie to prevent future errors. Exception message: #{error.message}"
          cookies.delete :deferred_action, domain: :all
        end
      else
        Rails.logger.debug "Action: #{action} not present on #{self.class}."
      end
    else
      Rails.logger.warn "Warning: action: #{action} not allowed on #{self.class}. User potentially tried to do Bad Things"
    end
  end

  # All deferred action methods should return true if the action completed successfully, otherwise false
  # If true is returned, the deferred action will be deleted
  # If false is returned, deferred action is preserved until next time deferred actions are executed (such as next time user logs in)
  #
  # Important: If an exception is raised and/or not caught by the deferred action method,
  # The caller will delete the deferred action, to prevent future errors. So if you can recover, catch the exception
  # and handle it here
  def create_subscription_deferred(params)
    return false if !logged_in? || current_user.provisional?

    create_subscription params

    true
  end

  def save_review_deferred(params)
    return false if !logged_in?

    save_review params

    true
  end

  def add_favorite_school_deferred(params)
    return false if !logged_in? || current_user.provisional?

    add_favorite_school params
    create_subscription params

    true
  end

  def report_review_deferred(params)
    return false if !logged_in? || current_user.provisional?

    flag_review_and_redirect params

    true
  end

  def saved_search_deferred(params)
    return false if !logged_in?

    handle_html params

    true
  end

  def self.included obj
    return unless obj < ActionController::Base
    obj.helper :all
  end

end
