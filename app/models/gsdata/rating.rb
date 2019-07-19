# frozen_string_literal: true

require 'ruby-prof'

class Rating < ActiveRecord::Base
  self.table_name = 'ratings'

  db_magic connection: :omni

  belongs_to :data_set

  # ratings
  def self.find_by_school_and_data_types_with_academics(school, configuration = default_configuration)

    # "SELECT distinct load_id FROM `data_values` WHERE (state = "#{school.state}"
    # AND district_id IS NULL AND school_id = "#{scool.id}" AND active = 1)"
    school_load_ids = DataValue.filter_query(school.state, nil, school.id).pluck(:load_id).uniq
    return unless school_load_ids.present?

    # select data_sets.id,
    #        data_sets.data_type_id,
    #        data_sets.configuration,
    #        data_sets.date_valid,
    #        data_sets.description,
    #        (sources.name)          as 'source_name',
    #        (data_types.name)       as 'data_type_name',
    #        (data_types.short_name) as 'data_type_short_name'
    # from data_sets,
    #      sources,
    #      data_types
    #     where
    #      data_sets.data_type_id = data_types.id
    #          and data_sets.source_id = sources.id
    #          and data_sets.id in
    #              (1, 4, 11, 18, 19, 20, 21, 22, 23,
    #               24, 25, 26, 27, 28, 29, 30, 31,
    #               32, 33, 34, 35, 36, 37, 38, 39,
    #               40, 41, 42, 43, 44, 45, 46, 47,
    #               48, 49, 50, 52, 55, 60, 61, 62,
    #               63, 64, 65, 66, 67, 68, 69, 70,
    #               71, 72, 73, 118, 164, 165, 734,
    #               735, 736, 737, 1634, 1635, 1636,
    #               1637, 1638, 1639, 1640, 1641,
    #               1850, 1851, 1929, 1930, 1932,
    #               3009, 3010, 3011, 3012)
    #          and (data_sets.configuration like '%none%' or data_sets.configuration like '%web%')
    loads = DataSet.data_type_ids_to_loads(configuration, school_load_ids)
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
