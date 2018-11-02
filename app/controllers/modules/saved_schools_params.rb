module SavedSchoolsParams
  def school_state
    params[:school]["state"]&.downcase
  end

  def school_id
    params[:school]["id"].to_i
  end

end