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
      Rails.logger.error(e.message + backtrace.join(" ")) if should_log?
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
        num_updated = UpdateQueue.where(status: unprocessed_status, concurrently: true, pid: nil).order(priority: :asc, created: :asc).limit(update_limit).update_all(pid: Process.pid)
        if num_updated > 0
          UpdateQueue.where(status: unprocessed_status, concurrently: true, pid: Process.pid).order(priority: :asc, created: :asc).limit(update_limit)
        else
          return []
        end
      else
        num_updated = UpdateQueue.where(status: unprocessed_status, pid: nil).order(priority: :asc, created: :asc).limit(update_limit).update_all(pid: Process.pid)
        if num_updated > 0
          UpdateQueue.where(status: unprocessed_status, pid: Process.pid).order(priority: :asc, created: :asc).limit(update_limit)
        else
          return []
        end
      end
    rescue => e
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
