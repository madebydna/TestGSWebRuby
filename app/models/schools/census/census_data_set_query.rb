class CensusDataSetQuery
  def self.attr_predicate(*boolean_attributes)
    boolean_attributes.each do |boolean_attribute|
      define_method "#{boolean_attribute}?" do
        instance_variable_get("@#{boolean_attribute}") == true
      end
    end
  end

  attr_reader :state, :school_id, :district_id, :relation
  attr_predicate :include_district_values,
                 :include_state_values,
                 :include_census_descriptions

  def initialize(state, relation = nil)
    @state = state
    @relation = relation || default_scope
    @include_district_values = false
    @include_state_values = false
    @include_census_descriptions = false
  end

  delegate :with_data_types, :with_subjects, to: :relation

  def default_scope
    CensusDataSet
      .on_db(state.downcase.to_sym)
      .active
  end

  def with_data_types(data_type_names_or_ids)
    @relation = @relation.with_data_types(data_type_names_or_ids)
    self
  end

  def with_subjects(subject_ids)
    @relation = @relation.where(subject_id: subject_ids)
    self
  end

  def with_school_values(school_id)
    @school_id = school_id
    @relation = @relation.eager_load(:census_data_school_values)
      .joins("AND census_data_school_value.school_id = #{school_id}")
    self
  end

  def with_district_values(district_id)
    @district_id = district_id
    @include_district_values = true
    self
  end

  def with_census_descriptions(school_type)
    @school_type = school_type
    @include_census_descriptions = true
    self
  end

  def results
    load_district_values if include_district_values?
    load_state_values if include_state_values?
    load_census_descriptions if include_census_descriptions?
    load_config_entries
    data_sets
  end
  alias_method :to_a, :results
  alias_method :all, :results

  def with_state_values
    @include_state_values = true
    self
  end

  def data_sets
    @data_sets ||= @relation.present? ? @relation.to_a : nil
  end

  def data_set_ids
    data_sets.map(&:id)
  end

  def load_district_values
    return if @district_values_loaded
    data_set_ids_to_district_values = district_values.group_by(&:data_set_id)
    data_sets.each do |data_set|
      district_values = Array(data_set_ids_to_district_values[data_set.id])
      association = data_set.association(:census_data_district_values)
      association.loaded!
      association.target.concat(district_values)
      district_values.each { |r| association.set_inverse_instance(r) }
    end
    @district_values_loaded = true
  end

  def district_values
    return [] if district_id.nil? || district_id == 0

    CensusDataDistrictValue
      .on_db(state.downcase.to_sym)
        .where(
          district_id: district_id,
          data_set_id: data_set_ids
        )
  end

  def load_state_values
    return if @state_values_loaded
    data_set_ids_to_state_values = state_values.group_by(&:data_set_id)
    data_sets.each do |data_set|
      state_values = Array(data_set_ids_to_state_values[data_set.id])
      association = data_set.association(:census_data_state_values)
      association.loaded!
      association.target.concat(state_values)
      state_values.each { |r| association.set_inverse_instance(r) }
    end
    @state_values_loaded = true
  end

  def state_values
    CensusDataStateValue
      .on_db(state.downcase.to_sym)
      .where(data_set_id: data_set_ids)
  end

  def census_descriptions
    CensusDescription.where(
      state: state,
      school_type: @school_type,
      census_data_set_id: data_set_ids
    )
  end

  def load_census_descriptions
    return if @census_descriptions_loaded
    census_descriptions.each do |description|
      data_sets.select { |cds| cds.id == description.census_data_set_id }
        .first.census_description = description
    end
    @census_descriptions_loaded = true
  end

  def config_entry_for_data_set(data_set)
    Array.wrap(
      CensusDataConfigEntry.for_data_set(
        state.downcase.to_sym,
        data_set
      )
    ).first
  end

  def load_config_entries
    return if @config_entries_loaded
    data_sets.each do |data_set|
      data_set.census_data_config_entry = config_entry_for_data_set data_set
    end
    # data_sets.select!(&:has_config_entry?)
    @config_entries_loaded = true
  end
end
