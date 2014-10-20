# Update queue daemon

def census_data_type?(datatype)
  CensusLoading::Base.census_data_types.key? datatype
end

def determine_loading_class(data_type)
  if census_data_type?(data_type)
    CensusLoading::Loader
  elsif data_type == 'newsletter'
    # ... just an example of how to extend
  else
    EspResponseLoading::Loader
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
        klass = determine_loading_class(data_type)
        loader = klass.new(data_type, update_blob[data_type], @scheduled_update.source)
        loader.load!
      end
      @scheduled_update.update_attributes(status: 'done')
    rescue Exception => e
      puts e.message
      @scheduled_update.update_attributes(status: 'failed', notes: e.message)
    end
  end
end

# This is just for testing
UpdateQueue.destroy_all
UpdateQueue.seed_sample_data!

puts 'Starting loops'
loop do
  process_unprocessed_updates
  sleep 2
end