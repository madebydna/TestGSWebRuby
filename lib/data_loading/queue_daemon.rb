class QueueDaemon

  UNPROCESSED_STATUS = 'todo'
  SUCCESS_STATUS = 'done'
  FAILURE_STATUS = 'failed'

  def run!
    # This is just for testing
    # UpdateQueue.destroy_all
    # UpdateQueue.seed_sample_data!

    puts 'Starting the update queue daemon.'
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
    sig_int = SignalHandler.new('INT')
    updates.each do |scheduled_update|
      sig_int.dont_interrupt do
        begin
          begin
            update_blob = JSON.parse(scheduled_update.update_blob)
          rescue Exception => e
            raise "Error parsing the JSON for this update. Error message: #{e.message}"
          end
          update_blob.each do |data_type, data_update|
            next if data_update.blank?
            klass = Loader.determine_loading_class(data_type)
            loader = klass.new(data_type, data_update, scheduled_update.source)
            loader.load!
          end
          scheduled_update.update_attributes(status: SUCCESS_STATUS, updated: Time.now)
        rescue Exception => e
          scheduled_update.update_attributes(status: FAILURE_STATUS, notes: e.message, updated: Time.now)
        end
      end
    end
  end
end
