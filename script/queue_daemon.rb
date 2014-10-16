# Update queue daemon

def all_census_data_types
  @all_census_data_type_names ||= Hash[CensusDataType.all.map { |cdt| [cdt.description, cdt.id] }]
end

def census_data_type?(datatype)
  all_census_data_types.key? datatype
end

def convert_breakdown_to_id(breakdown)
  if breakdown
    # TODO memoize all ethnicities
    eth = Ethnicity.where(name: breakdown).first
    if eth
      CensusDataBreakdown.where(ethnicity_id: eth.id).first.id
    else
      raise "Unknown ethnicity: #{breakdown}"
    end
  end
end

def convert_subject_to_id(subject)
  if subject
    # TODO memoize all subjects
    sub = TestDataSubject.where(name: subject).first
    if sub
      sub.id
    else
      raise "Unknown subject: #{subject}"
    end
  end
end

def process_data_as_census(data_type, updates)
  puts __method__
  data_type_id = all_census_data_types[data_type]
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
                                                 modifiedBy: "Queue daemon. Source: #{@scheduled_update.source}")

    @scheduled_update.update_attributes(status: 'done')
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

def process_data_as_esp(data_type, updates)
  puts __method__
end

def determine_method(data_type)
  if census_data_type?(data_type)
    :process_data_as_census
  elsif data_type == 'newsletter'
    # ... just an example of how to extend
  else
    :process_data_as_esp
  end
end

def process_unprocessed_updates
  begin
    updates = UpdateQueue.todo
  rescue
    raise 'Could not find UpdateQueue table'
  end
  updates.each do |scheduled_update|
    @scheduled_update = scheduled_update
    begin
      begin
        update_blob = JSON.parse(@scheduled_update.update_blob)
      rescue
        raise 'Invalid JSON in update_blob'
      end
      data_types = update_blob.keys
      data_types.each do |data_type|
        method = determine_method(data_type)
        send(method, data_type, update_blob[data_type])
      end
    rescue Exception => e
      @scheduled_update.update_attributes(status: 'failed', notes: e.message)
    end
  end
end

# This is just for testing
UpdateQueue.destroy_all
UpdateQueue.seed_sample_data!

loop do
  process_unprocessed_updates
  sleep 2
end