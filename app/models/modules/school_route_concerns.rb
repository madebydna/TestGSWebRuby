# Contains code to support routing school profile requests
module SchoolRouteConcerns
  NEW_PROFILE_FLAG = 5
  def for_new_profile?
    self.new_profile_school == NEW_PROFILE_FLAG
  end
end