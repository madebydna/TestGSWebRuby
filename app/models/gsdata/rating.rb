# frozen_string_literal: true

require 'ruby-prof'

class Rating < ActiveRecord::Base
  self.table_name = 'ratings'

  db_magic connection: :omni

  belongs_to :data_set

  # ratings
  def self.find_by_school_and_data_types_with_academics(school, data_types, configuration = default_configuration)

    # "SELECT distinct load_id FROM `data_values` WHERE (state = "#{school.state}"
    # AND district_id IS NULL AND school_id = "#{scool.id}" AND active = 1)"
    school_load_ids = DataValue.filter_query(school.state, nil, school.id).pluck(:load_id).uniq
    return unless school_load_ids.present?
    loads = DataSet.data_type_ids_to_loads(data_types, configuration, school_load_ids )
    # loads = Load.data_type_ids_to_loads(data_types, configuration, school_load_ids )
    return unless loads.present?

    dvs = dvs(loads, school)
    combine_dvs_loads(loads, dvs)
  end

  def self.dvs(loads, school)
    DataValue
        .school_values_with_academics
        .from(DataValue.filter_query(school.state, nil, school.id, load_ids(loads)), :data_values)
        .with_academics
        .with_academic_tags
        .with_breakdowns
        .with_breakdown_tags
        .group('data_values.id')
        .having("(breakdown_count + academic_count) < 3 OR breakdown_names like '%All students except 504 category%'")
  end

  def self.combine_dvs_loads(loads, dvs)
    GsdataCaching::LoadDataValue.new(loads, dvs).merge
  end

  def self.default_configuration
    %w(none web)
  end

  def self.load_ids(loads)
    loads&.map(&:id)&.uniq
  end

end
