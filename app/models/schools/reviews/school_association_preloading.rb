# To be mixed in to an array of ActiveRecord models that each have a state and school ID
module SchoolAssociationPreloading

  def self.extended(object)
    unless object.is_a?(Enumerable) || object.is_a?(ActiveRecord::Relation)
      raise ArgumentError.new(
              "SchoolAssociationPreloading must be mixed into an ActiveRecord relation or an Enumerable object, such as an array. "\
              "Attempted to mix it into a #{object.class}"
            )
    end
    unless object.first.respond_to?(:state) || object.first.nil?
      raise ArgumentError.new(
              "SchoolAssociationPreloading must be mixed into Enumerable models that each respond to .state and .school_id. "\
              "First model of type #{object.first.class} does not respond to .state"
            )
    end
    unless object.first.respond_to?(:school_id) || object.first.nil?
      raise ArgumentError.new(
              "SchoolAssociationPreloading must be mixed into Enumerable models that each respond to .state and .school_id. "\
              "First model of type #{object.first.class} does not respond to .school_id"
            )
    end
  end

  def preload_associated_schools!
    return unless present?

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