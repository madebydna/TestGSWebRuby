module SchoolTypeConcerns
  def decorated_school_type
    if type.to_s.downcase == 'charter'
      'Public charter'
    elsif type.to_s.downcase == 'public'
      'Public district'
    else
      'Private'
    end
  end
end