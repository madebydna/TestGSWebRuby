class QueueDaemon

  UNPROCESSED_STATUS = 'todo'
  SUCCESS_STATUS = 'done'
  FAILURE_STATUS = 'failed'

  def run!
    # This is just for testing
    # UpdateQueue.destroy_all
    # UpdateQueue.seed_sample_data!

    puts 'Starting loops'
    loop do
      process_unprocessed_updates
      sleep 2
    end
  end

  def process_unprocessed_updates
    begin
      updates = UpdateQueue.where(status: UNPROCESSED_STATUS).limit(100)
    rescue
      raise 'Could not find UpdateQueue table'
    end
    updates.each do |scheduled_update|
      begin
        begin
          update_blob = JSON.parse(scheduled_update.update_blob)
        rescue
          raise 'Invalid JSON in update_blob'
        end
        update_blob.each do |data_type, data_update|
          klass = Loader.determine_loading_class(data_type)
          loader = klass.new(data_type, data_update, scheduled_update.source)
          loader.load!
        end
        scheduled_update.update_attributes(status: SUCCESS_STATUS)
      rescue Exception => e
        puts e.message
        scheduled_update.update_attributes(status: FAILURE_STATUS, notes: e.message)
      end
    end
  end
end

daemon = QueueDaemon.new
daemon.run!
