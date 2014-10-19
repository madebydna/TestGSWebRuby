class CensusLoading::Loader < CensusLoading::Base

  include CensusLoading::Breakdowns
  include CensusLoading::Subjects

  # TODO handle census_description, census_data_set_file
  # TODO break out data set code into module

  def load!
    puts self.class
    data_type_id = census_data_types[data_type].id
    updates.each do |update|
      parse_census_update_attributes!(update, data_type_id)

      # Can't use first_or_create because of sharding :(
      # data_set = CensusDataSet.on_db(@shard).where(@data_set_attributes).first_or_create
      data_sets = CensusDataSet.on_db(@shard).where(@data_set_attributes)
      data_set = if data_sets.size == 1
                   data_sets.first
                 elsif data_sets.size == 0
                   CensusDataSet.on_db(@shard).create(@data_set_attributes)
                 else
                   raise "More than 1 dataset found for shard #{@shard} and attributes #{@data_set_attributes}"
                 end

      @value_record_attributes.merge! data_set_id: data_set.id
      value_record = @value_class.on_db(@shard).where(@value_record_attributes).first_or_initialize
      # TODO figure out value type (text or float) from data type
      value_record.on_db(@shard).update_attributes(active: true,
                                                   value_float: @value,
                                                   modified: Time.now,
                                                   modifiedBy: "Queue daemon. Source: #{source}")

    end
  end

  def parse_census_update_attributes!(update, data_type_id)
    state, entity_type, entity_id, @value = update.values_at('entity_state','entity_type','entity_id','value')
    @shard = state.to_s.downcase.to_sym

    @value_record_attributes = {
        "#{entity_type.downcase}_id".to_sym => entity_id
    }

    year, grade, breakdown, subject, breakdown_id, subject_id = update.values_at('year','grade','breakdown','subject', 'breakdown_id', 'subject_id')
    year = year.to_i # Will default to 0
    grade = grade.to_s if grade
    breakdown_id = convert_breakdown_to_id(breakdown) || breakdown_id
    subject_id = convert_subject_to_id(subject) || subject_id

    @data_set_attributes = { year: year,
                             grade: grade,
                             breakdown_id: breakdown_id,
                             subject_id: subject_id,
                             data_type_id: data_type_id
    }
    @value_class = "CensusData#{entity_type.titleize}Value".constantize
  end
end
