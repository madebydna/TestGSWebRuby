module SavedSchoolsParams
  def school_state
    params[:school]["state"]&.downcase
  end

  def school_id
    params[:school]["id"].to_i
  end

  def db_schools
    FavoriteSchool.saved_school_list(current_user)
  end
end