class CensusDataSet < ActiveRecord::Base
  self.table_name = 'census_data_set'
  self.inheritance_column = nil

  include ReadOnlyRecord
  include StateSharding
  include LookupDataPreloading

  attr_accessor :census_description, :census_data_config_entry

  has_many :census_data_school_values, class_name: 'CensusDataSchoolValue', foreign_key: 'data_set_id'
  has_many :census_data_district_values, class_name: 'CensusDataDistrictValue', foreign_key: 'data_set_id'
  has_many :census_data_state_values, class_name: 'CensusDataStateValue', foreign_key: 'data_set_id'
  belongs_to :census_data_breakdown, foreign_key: 'breakdown_id'

  delegate :value, :modified, :modified_by,
           to: :census_data_school_value, prefix: 'school', allow_nil: true
  delegate :value, :modified, :modified_by,
           to: :census_data_district_value, prefix: 'district', allow_nil: true
  delegate :value, :modified, :modified_by,
           to: :census_data_state_value, prefix: 'state', allow_nil: true

  delegate :value_int,
           to: :census_data_school_value, prefix: 'school', allow_nil: true

  delegate :source, to: :census_description, allow_nil: true

  # If we only want one field from a lookup table, we can do this
  # Which would give us a new method on this object called data_type, which would read from the description column
  # from the census_data_type table
  #
  # preload_all :census_data_type, :as => :data_type, :foreign_key => :data_type_id, :field => :description

  # In this case we want the whole object, since there are two fields we need
  preload_all :census_data_type, :as => :census_data_type, :foreign_key => :data_type_id
  def data_type
    census_data_type.description if census_data_type
  end
  def data_format
    census_data_type.type if census_data_type
  end


  def census_data_school_value
    census_data_school_values[0] if census_data_school_values.any?
  end
  def census_data_district_value
    census_data_district_values[0] if census_data_district_values.any?
  end
  def census_data_state_value
    census_data_state_values[0] if census_data_state_values.any?
  end

  def has_config_entry?
    census_data_config_entry != nil
  end

  def config_entry_breakdown_label
    census_data_config_entry.label if has_config_entry?
  end

  scope :with_data_types, lambda { |data_type_names_or_ids|
    data_type_ids = CensusDataType.data_type_ids(data_type_names_or_ids)
    where(data_type_id: Array(data_type_ids))
  }

  scope :with_max_years_for_data_types, lambda { |state, data_type_ids|
    max_years = max_year_per_data_type(state)
    years = max_years.select { |data_type_id| data_type_ids.include? data_type_id }.values
    years << 0

    where(year: years)
  }

  scope :active, where(active: true)

  def self.census_data_for_school_and_data_type_ids(school, data_type_ids = [])
    school_conditions = reflect_on_association(:census_data_school_values).options[:conditions]
    district_conditions = reflect_on_association(:census_data_district_values).options[:conditions]

    reflect_on_association(:census_data_school_values).options[:conditions] = "school_id = #{school.id}"
    reflect_on_association(:census_data_district_values).options[:conditions] = "district_id = #{school.district_id}"

    census_data_sets =
      on_db(school.shard)
      .active
      .with_data_types(data_type_ids)
      .eager_load(:census_data_school_values)
      .eager_load(:census_data_district_values)
      .eager_load(:census_data_state_values)
      .all

    # Put back the association conditions the way they were
    # The records must have already been retrieved from the db
    reflect_on_association(:census_data_school_values).options[:conditions] = school_conditions
    reflect_on_association(:census_data_district_values).options[:conditions] = district_conditions

    # TODO: find better way to make the model instances know which shard they came from
    census_data_sets.each { |data_set| data_set.instance_variable_set :@shard, school.shard }

    descriptions = CensusDescription.for_data_sets_and_school(census_data_sets, school)

    descriptions.each do |description|
      census_data_sets.select { |cds| cds.id == description.census_data_set_id }.first.census_description = description
    end

    census_data_sets
  end

  def self.max_year_per_data_type(state)
    Rails.cache.fetch("census_data_set/max_year_per_data_type/#{state}", expires_in: 5.minutes) do
      on_db(state.downcase.to_sym).having_school_values.group(:data_type_id).maximum(:year)
    end
  end

  def to_hash
    Hashie::Mash.new(
      data_type: data_type,
      year: year,
      grade: grade,
      subject: subject_id, #TODO: change to subject object or string
      level_code: level_code,
      breakdown: census_breakdown || '',
      school_value: school_value,
      district_value: district_value,
      school_value_int: int_value,
      state_value: state_value
    )
  end

  def census_breakdown
    return nil
    census_data_breakdown.breakdown if census_data_breakdown
  end

end
