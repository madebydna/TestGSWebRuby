module FavoriteSchoolsConcerns
  extend ActiveSupport::Concern

  def add_favorite_school(params)
    begin
      school_id = params[:school_id]
      state = params[:state]
      school = nil

      if school_id.present? && state.present?
        begin
          school = School.on_db(state.downcase.to_sym).find school_id
        rescue
          Rails.logger.debug($!)
        end
      end

      if school.nil?
        raise "Could not find school for state #{state} and id #{school_id}"
      end

      unless current_user.favorited_school? school
        current_user.add_favorite_school! school
      end
      flash_notice t('actions.my_school_list.school_added', school_name: school.name)
    rescue => e
      flash_error e.message
      raise e
    end
  end

end