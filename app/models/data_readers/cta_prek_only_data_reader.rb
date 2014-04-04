class CtaPrekOnlyDataReader < SchoolProfileDataReader

  def data_for_category(_)
    school.preschool? ? nil : "Show Module"
  end

end