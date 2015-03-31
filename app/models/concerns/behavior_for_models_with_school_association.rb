# To be used on a model that is associated to a school, when the model is not sharded, but school is sharded
module BehaviorForModelsWithSchoolAssociation
  extend ActiveSupport::Concern

  included do
    def self.find_by_school(school)
      query = where(school_id: school.id, school_state: school.state)
      query = query.active if respond_to?(:active)
    end
  end

  def school
    @school ||= School.on_db(state.downcase.to_sym).find(school_id) rescue nil
  end

  def school=(school)
    self.school_state = school.state
    self.school_id = school.id
  end

end