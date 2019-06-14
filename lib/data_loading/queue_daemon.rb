class QueueDaemon
  UNPROCESSED_STATUS = 'todo'
  SUCCESS_STATUS = 'done'
  FAILURE_STATUS = 'failed'
  UPDATE_LIMIT_DEFAULT = 5
  DEFAULT_FAIL_MSG = 'Could not find UpdateQueue table'
  MAX_FAIL_COUNTER = 10
  FAIL_SLEEP_TIME = 10

  attr_accessor :should_log

  def initialize(concurrently: false)
    @concurrently = concurrently
  end

  def run!
    fail_counter = 0
    if ENV['RAILS_ENV'] == 'production'
      ActiveRecord::Base.establish_connection(ActiveRecord::Base.configurations['mysql_production_rw'])
    end

    puts ('Using Data base host '+ActiveRecord::Base.connection.instance_variable_get(:@config)[:host])
    puts 'Starting the update queue daemon.'
    puts 'In concurrent mode.' if @concurrently
    loop do
      begin
        num_processed = process_unprocessed_updates
        fail_counter = 0
        sleep ENV_GLOBAL['queue_daemon_sleep_time'] if num_processed == 0
      rescue => e
        fail_counter += 1
        if fail_counter > MAX_FAIL_COUNTER || e.message != DEFAULT_FAIL_MSG
          puts "Too many errors, quitting"
          GSLogger.error(:misc, e, message: 'Bubbling up exception from QueueDaemon#run!')
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
    rescue Exception => e
      GSLogger.error(:misc, e, message: 'Exception processing updates')
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
          backtrace = e.backtrace.reject { |t| t['/gems/'] }
          Rails.logger.error(e.message + backtrace.join(" ")) if should_log?
          scheduled_update.update_attributes(status: FAILURE_STATUS, notes: e.message + backtrace.join(" "), updated: Time.now)
        ensure
          print_status_summary
        end
      end
    end
    updates.size
  end

  # Our general approach to queue_daemon data loads: insert a bunch of rows to load data (serially), then
  # insert a bunch of rows to rebuild the caches (concurrently). The intent of this method is to have our concurrent
  # daemons WAIT until all the serial rows complete before attempting to rebuild the caches. They do this by checking
  # for any serial rows inserted prior to the first concurrent row they see. If they find one, abort. Otherwise, continue.
  #
  # For the concurrent check, only interested in the actual next row we would process. So pid nil by priority, created etc.
  #
  # For the serial check, only interested in created date (not priority), but want to include ones that are already
  # claimed as long as they are still in progress (so no pid check). Reason we don't care about priority is we don't
  # really care if the next row the daemon would process is some high priority parent review, what we want to know is
  # if there are any data load rows remaining that were inserted prior to that concurrent data_refresh row.
  def safe_to_run?
    return true unless concurrently? # This check only applies to concurrent daemons

    max_created_concurrent = UpdateQueue.where(status: unprocessed_status, concurrently: true, pid: nil).order(priority: :asc, created: :asc).limit(1).pluck(:created).first
    max_created_serial = UpdateQueue.where(status: unprocessed_status, concurrently: false).order(created: :asc).limit(1).pluck(:created).first

    return true if max_created_serial.nil? # Always safe to run if no serial rows exist
    return false if max_created_concurrent.nil? # No need to proceed if no concurrent rows exist
    # Safe to run only if the first serial row was created after the first concurrent row
    max_created_serial > max_created_concurrent
  end

  def print_status_summary
    return unless should_log?
    hash = UpdateQueue.group(:status).count.symbolize_keys
    hash.reverse_merge!(todo: 0, failed: 0, done: 0)
    print hash.map { |status, count|  "#{status}: #{count.to_s.ljust(10)}" }.join(' ') + "\r"
    $stdout.flush
  end

  def should_log?
    @should_log
  end

  def concurrently?
    @concurrently == true
  end

  def get_updates
    begin
      if concurrently?
        if safe_to_run?
          # Need to force R/W usage here otherwise DB Charmer may get fooled and pick the R/O
          UpdateQueue.on_db(:gs_schooldb_rw) do
            UpdateQueue.where(status: unprocessed_status, concurrently: true, pid: nil).order(priority: :asc, created: :asc).limit(update_limit).update_all(pid: Process.pid)
            UpdateQueue.where(status: unprocessed_status, concurrently: true, pid: Process.pid).order(priority: :asc, created: :asc).limit(update_limit)
          end
        else
          return []
        end
      else
        # Need to force R/W usage here otherwise DB Charmer may get fooled and pick the R/O
        UpdateQueue.on_db(:gs_schooldb_rw) do
          UpdateQueue.where(status: unprocessed_status, pid: nil).order(priority: :asc, created: :asc).limit(update_limit).update_all(pid: Process.pid)
          UpdateQueue.where(status: unprocessed_status, pid: Process.pid).order(priority: :asc, created: :asc).limit(update_limit)
        end
      end
    rescue => e
      GSLogger.error(:misc, e, message: 'Exception getting updates')
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
