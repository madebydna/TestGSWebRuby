# To be used on a model that is associated to a school, when the model is not sharded, but school is sharded
module BehaviorForModelsWithSchoolAssociation
  extend ActiveSupport::Concern

  included do
    # find_by_school(school: my_school) or find_by_school(school_id: 1, state: 'ca')
    def self.find_by_school(school_or_hash)
      hash = {}
      school_id = nil
      school_state = nil

      if school_or_hash.is_a?(School)
        school = school_or_hash
        school_id = school.id
        school_state = school.state
      else
        hash = school_or_hash
        if hash[:school]
          school_id = hash[:school].id
          school_state = hash[:school].state
        elsif hash[:state] && hash[:school_id]
          school_id = hash[:school_id]
          school_state = hash[:state]
        else
          raise(ArgumentError, "Must provide :school or :state and :school_id")
        end
      end

      conditions = { school_id: school_id, school_state: school_state }
      conditions.merge!(active: true) if respond_to?(:active)
      query = where(conditions)
    end
  end

  def school
    if school_id && school_state
      @school ||= School.on_db(school_state.downcase.to_sym).find(school_id) rescue nil
    end
  end

  def school=(school)
    @school = school
    self.school_state = school.state
    self.school_id = school.id
  end

end