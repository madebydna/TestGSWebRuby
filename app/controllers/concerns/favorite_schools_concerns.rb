module FavoriteSchoolsConcerns
  extend ActiveSupport::Concern

  protected

  def add_favorite_school(params)
    begin
      school_id = Array.wrap(params[:school_id])
      state = Array.wrap(params[:state])

      if school_id.count != state.count
        raise "state and school_id mismatch school_ids count #{school_id.count} with state count #{state.count}"
      end

      school_id.each_with_index {|sch_id, index|
        school = nil

        if sch_id.present? && state[index].present?
          school = School.find_by_state_and_id state[index], sch_id
        end

        if school.nil?
          raise "Could not find school for state #{state} and id #{school_id}"
        end

        unless current_user.favorited_school? school
          current_user.add_favorite_school! school
          set_omniture_events_in_cookie(['review_updates_mss_end_event'])
          set_omniture_sprops_in_cookie({'custom_completion_sprop' => 'AddToSchoolList'})
        end
        flash_notice t('actions.my_school_list.school_added', school_name: school.name)
      }
    rescue => e
      flash_error e.message
      raise e
    end
  end

  def self.included obj
    return unless obj < ActionController::Base
    obj.helper :all
  end

end