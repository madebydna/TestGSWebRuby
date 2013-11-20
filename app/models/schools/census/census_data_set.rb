class CensusDataSet < ActiveRecord::Base
  self.table_name = 'census_data_set'
  self.inheritance_column = nil

  include ReadOnlyRecord
  include StateSharding
  include LookupDataPreloading

  #has_lookup :census_data_type, :class_name => 'CensusDataType', :foreign_key => 'data_type_id'

  has_many :census_data_school_values, class_name: 'CensusDataSchoolValue', foreign_key: 'data_set_id'
  has_many :census_data_district_values, class_name: 'CensusDataDistrictValue', foreign_key: 'data_set_id'
  has_many :census_data_state_values, class_name: 'CensusDataStateValue', foreign_key: 'data_set_id'
  has_one :census_breakdown, foreign_key: 'datatype_id'

  delegate :value, :modified, :modified_by,
           to: :census_data_school_value, prefix: 'school', allow_nil: true
  delegate :value, :modified, :modified_by,
           to: :census_data_state_value, prefix: 'state', allow_nil: true
  delegate :value_int,
           to: :census_data_school_value, prefix: 'school', allow_nil: true


  # If we only want one field from a lookup table, we can do this
  # Which would give us a new method on this object called data_type, which would read from the description column
  # from the census_data_type table
  #
  # preload_all :census_data_type, :as => :data_type, :foreign_key => :data_type_id, :field => :description

  # In this case we want the whole object, since there are two fields we need
  preload_all :census_data_type, :as => :census_data_type, :foreign_key => :data_type_id
  def data_type; census_data_type.description; end
  def data_format; census_data_type.type; end


  def census_data_school_value
    census_data_school_values[0] if census_data_school_values.any?
  end
  def census_data_state_value
    census_data_state_values[0] if census_data_state_values.any?
  end

  scope :with_data_types, lambda { |data_type_ids|
    where(data_type_id: Array(data_type_ids))
  }

  scope :with_max_years_for_data_types, lambda { |state, data_type_ids|
    max_years = max_year_per_data_type(state)
    years = max_years.select { |data_type_id| data_type_ids.include? data_type_id }.values
    years << 0

    where(year: years)
  }

  scope :include_school_district_state, lambda { |school_id|
    includes(:census_data_school_values).where('census_data_school_value.school_id = ?',school_id)
    .includes(:census_data_state_values)
  }

  scope :active, where(active: true)

  def self.max_year_per_data_type(state)
    Rails.cache.fetch("census_data_set/max_year_per_data_type/#{state}", expires_in: 5.minutes) do
      on_db(state.downcase.to_sym).having_school_values.group(:data_type_id).maximum(:year)
    end
  end

  scope :having_school_values, joins(:census_data_school_values)

  def to_hash
    Hashie::Mash.new(
      data_type: data_type,
      year: year,
      grade: grade,
      subject: subject_id, #TODO: change to subject object or string
      level_code: level_code,
      breakdown: census_breakdown || '',
      school_value: school_value,
      school_value_int: int_value,
      state_value: state_value
    )
  end

  def census_breakdown
    # TODO: fix hardcoded value
    #CensusBreakdown.using(:master).where(datatype_id: '11', id: lookup[breakdown_id]).first
    breakdown = lookup[breakdown_id]
    lookup_breakdown_text[breakdown]
  end

  def lookup_breakdown_text
    {
      1 => 'White, non-Hispanic',
      2 => 'Black, non-Hispanic',
      3 => 'Hispanic',
      4 => 'American Indian/Alaskan Native',
      5 => 'Asian/Pacific Islander',
      6 => 'Multiracial',
      7 => 'Asian',
      8 => 'Pacific Islander',
      10 => 'Native American or Native Alaskan',
      11 => 'Hawaiian',
      12 => 'Unspecified',
      13 => 'Filipino',
      14 => 'Native Hawaiian or Other Pacific Islander'
    }
  end

  def lookup
    {
      1 => 1,
      2 => 2,
      3 => 3,
      4 => 4,
      5 => 5,
      6 => 6,
      7 => 7,
      8 => 8,
      9 => 9,
      10 => 10,
      11 => 11,
      12 => 12,
      162 => 13,
      209 => 14,
      201 => 18,
      202 => 15,
      203 => 16,
      204 => 17,
      207 => 19,
      208 => 20
    }
  end

end
