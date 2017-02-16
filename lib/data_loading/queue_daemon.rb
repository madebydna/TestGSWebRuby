class QueueDaemon
  UNPROCESSED_STATUS = 'todo'
  SUCCESS_STATUS = 'done'
  FAILURE_STATUS = 'failed'
  UPDATE_LIMIT_DEFAULT = 5
  DEFAULT_FAIL_MSG = 'Could not find UpdateQueue table'
  MAX_FAIL_COUNTER = 10
  FAIL_SLEEP_TIME = 10

  def run!
    fail_counter = 0
    if ENV['RAILS_ENV'] == 'production'
      ActiveRecord::Base.establish_connection(ActiveRecord::Base.configurations['mysql_production_rw'])
    end

    puts ('Using Data base host '+ActiveRecord::Base.connection.instance_variable_get(:@config)[:host])
    puts 'Starting the update queue daemon.'
    loop do
      begin
        num_processed = process_unprocessed_updates
        fail_counter = 0
        sleep ENV_GLOBAL['queue_daemon_sleep_time'] if num_processed == 0
      rescue => e
        fail_counter += 1
        if fail_counter > MAX_FAIL_COUNTER || e.message != DEFAULT_FAIL_MSG
          puts "Too many errors, quitting"
          raise e
        end
        puts "Can't connect to database to list updates. Will try again in #{FAIL_SLEEP_TIME} seconds"
        sleep FAIL_SLEEP_TIME
      end
    end
  end

  def process_unprocessed_updates
    begin
      updates = get_updates
    rescue
      raise DEFAULT_FAIL_MSG
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
            klass = Loader.determine_loading_class(scheduled_update.source, data_type)
            loader = klass.new(data_type, data_update, scheduled_update.source)
            loader.load!
          end
          scheduled_update.update_attributes(status: SUCCESS_STATUS, updated: Time.now)
        rescue Exception => e
          scheduled_update.update_attributes(status: FAILURE_STATUS, notes: e.message, updated: Time.now)
        end
      end
    end
    updates.size
  end

  def get_updates
    begin
      UpdateQueue.where(status: unprocessed_status).order(priority: :asc, created: :asc).limit(update_limit)
    rescue
      raise 'Could Not Retrieve Updates'
    end
  end

  def unprocessed_status
    UNPROCESSED_STATUS
  end

  def update_limit
    ENV_GLOBAL['queue_daemon_updates_limit'].to_i || UPDATE_LIMIT_DEFAULT
  end
end
