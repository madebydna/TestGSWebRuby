module FavoriteSchoolsConcerns
  extend ActiveSupport::Concern

  protected

  def add_favorite_school(params)
    begin
      school_id = params[:school_id].to_s
      state = params[:state].to_s
      user = User.find_by_email(params[:email]) if params[:email]
      user ||= current_user

      raise(ArgumentError, "can't find user from email param \"#{params[:email]}\" or cookie") if user.nil?

      if school_id.present? && state.present?
        school_id = school_id.split(/,/)
        state = state.split(/,/)
      else
        raise(ArgumentError, "state and school_id both need to be present to follow the school")
      end

      if school_id.count != state.count
        raise(ArgumentError, "state and school_id mismatch school_ids count #{school_id.count} with state count #{state.count}")
      end
      school_names = []
      school_id.each_with_index {|sch_id, index|
        school = nil
        if sch_id.present? && state[index].present?
          school = School.find_by_state_and_id state[index], sch_id

        end
        if school.nil?
          raise(ArgumentError, "Could not find school for state #{state} and id #{school_id}")
        end
        school_names.push(school.name)
        unless user.favorited_school? school
          user.add_favorite_school! school
          set_omniture_events_in_cookie(['review_updates_mss_end_event'])
          set_omniture_sprops_in_cookie({'custom_completion_sprop' => 'AddToSchoolList'})
        end

      }
      flash_notice t('actions.my_school_list.school_added_subscribed', school_name: school_names.to_sentence(locale: I18n.locale)).html_safe
    rescue ArgumentError
      flash_error t('actions.generic_error')
    rescue => e
      GSLogger.error(:misc, e, message:'Error saving user favorites', vars: params)
      flash_error t('actions.generic_error')
    end
  end

  def self.included obj
    return unless obj < ActionController::Base
    obj.helper :all
  end

end