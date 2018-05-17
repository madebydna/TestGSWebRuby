# frozen_string_literal: true

require 'set'

class DataValuesForSchoolQuery

  # public methods we might need to add
  # #include_ratings
  # #include_test_data

  # school_id can be an array if you want rows for multiple schools
  # for the same state
  def initialize(relation=DataValue.all, state:, school_id:)
    @data_type_ids = []
    @relation = relation
    @state = state
    @school_id = school_id
  end

  def include_summary_rating
    @data_type_ids << 160
    @data_type_ids << 176
    self
  end

  def include_sources
    @relation =
      @relation
        .select('sources.source_name, sources.date_valid as date_valid')
        .with_sources
    self
  end

  def data_values_subselect
    DataValue.where(
      state: @state,
      district_id: nil,
      school_id: @school_id,
      data_type_id: @data_type_ids
    )
  end

  def include_data_values
    @relation = 
      @relation
        .from(data_values_subselect, :data_values)
        .select('data_values.*')
    self
  end

  def run
    include_data_values
    include_sources
    @relation.to_a.extend(Gsdata::DataValueCollectionMethods)
  end

end
