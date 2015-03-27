class QueueDaemon

  UNPROCESSED_STATUS = 'todo'
  SUCCESS_STATUS = 'done'
  FAILURE_STATUS = 'failed'
  UPDATE_LIMIT_DEFAULT = 100
  #1 is the highest priority and 5 is the lowest. updates will get processed in order of highest to lowest
  UPDATE_ORDER_DEFAULT = [1,2,3,4,5]

  def run!
    # This is just for testing
    # UpdateQueue.destroy_all
    # UpdateQueue.seed_sample_data!

    puts 'Starting the update queue daemon.'
    loop do
      process_unprocessed_updates
      sleep ENV_GLOBAL['queue_daemon_sleep_time']
    end
  end

  def process_unprocessed_updates
    begin
      updates = get_updates
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
            klass = Loader.determine_loading_class(scheduled_update.source,data_type)
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

  def get_updates
    begin
      UpdateQueue.find_by_sql(updates_query)
    rescue
      raise 'Could Not Retrieve Updates'
    end
  end

  def updates_query
    todo, limit, order = unprocessed_status, update_limit, update_order


    # Orders the select statements based on the order in the array
    # So if the array is [4,1,3,5,2] then that is the order the selects will be
    # In other words the order in which the priority items will be processed
    query = order.inject('') do |q, order_number|
      q << "(SELECT * FROM update_queue WHERE `status` = #{todo} AND `priority` = #{order_number} ORDER BY `created` ASC LIMIT #{limit}) UNION ALL"
    end

    query << <<-eos
      (SELECT * FROM update_queue WHERE `status` = #{todo} AND `priority` NOT IN (#{order.join(',')}) ORDER BY `priority`, `created` ASC LIMIT #{limit})
      LIMIT #{limit}
    eos
  end

  # An Example Query from updates_query if update_order = [1, 2, 3, 4, 5]
  # (SELECT * FROM update_queue WHERE `status` = 'todo' AND `priority` = 1 ORDER BY `created` ASC LIMIT 100) UNION ALL
  # (SELECT * FROM update_queue WHERE `status` = 'todo' AND `priority` = 2 ORDER BY `created` ASC LIMIT 100) UNION ALL
  # (SELECT * FROM update_queue WHERE `status` = 'todo' AND `priority` = 3 ORDER BY `created` ASC LIMIT 100) UNION ALL
  # (SELECT * FROM update_queue WHERE `status` = 'todo' AND `priority` = 4 ORDER BY `created` ASC LIMIT 100) UNION ALL
  # (SELECT * FROM update_queue WHERE `status` = 'todo' AND `priority` = 5 ORDER BY `created` ASC LIMIT 100) UNION ALL
  # (SELECT * FROM update_queue WHERE `status` = 'todo' AND `priority` NOT IN (1,2,3,4,5) ORDER BY `priority`, `created` ASC LIMIT 100)
  # LIMIT 100

  def unprocessed_status
    ActiveRecord::Base.sanitize(UNPROCESSED_STATUS)
  end

  def update_limit
    ENV_GLOBAL['queue_daemon_updates_limit'].to_i || UPDATE_LIMIT_DEFAULT
  end

  def update_order
    order = ENV_GLOBAL['queue_daemon_update_order']
    if order.is_a? Array
      order.each { |order_number| return UPDATE_ORDER_DEFAULT unless order_number.is_a? Fixnum }
    else
      UPDATE_ORDER_DEFAULT
    end
  end

end
