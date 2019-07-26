# To be mixed in to an array of ActiveRecord models that each have a state and school ID
module SchoolAssociationPreloading

  def self.extended(object)
    unless object.is_a?(ActiveRecord::Relation)
      raise ArgumentError.new(
              "SchoolAssociationPreloading must be mixed into an ActiveRecord relation. "\
              "Attempted to mix it into a #{object.class}"
            )
    end
    unless object.klass.method_defined?(:state) || object.klass.attribute_method?("state")
      raise ArgumentError.new(
              "SchoolAssociationPreloading must be mixed into ActiveRecord models that respond to .state and .school_id. "\
              "#{object.klass} does not respond to .state"
            )
    end
    unless object.klass.method_defined?(:school_id) || object.klass.attribute_method?("school_id")
      raise ArgumentError.new(
              "SchoolAssociationPreloading must be mixed into ActiveRecord models that respond to .state and .school_id. "\
              "#{object.klass} does not respond to .school_id"
            )
    end
  end

  # This method is intended to exist on an array of ActiveRecord objects
  #
  # Pool up all the states and school IDs for all of my objects
  # Ask the School class to go find all the schools for those states and IDs
  # When the results come back, we need to preload each school onto the appropriate model
  # To do this efficiently, create a map of { state + school ID => school }
  # Go through all the models, and using the same state + school ID key, look up the correct school
  # Set a @school instance variable on the model, with the assumption that the model will know
  # to use it (see behavior_for_models_with_school_association.rb)
  def preload_associated_schools!
    return self unless present?

    make_key = Proc.new { |state, id| "#{state}_#{id}" }
    states = map(&:state)
    ids = map(&:school_id)
    schools = School.for_states_and_ids(states, ids)
    key_to_school_map = schools.each_with_object({}) { |school, hash| hash[make_key.call(school.state, school.id)] = school }

    each do |model|
      model.instance_variable_set(
        :@school,
        key_to_school_map[
          make_key.call(model.state, model.school_id)
        ]
      )
    end

    self
  end

end