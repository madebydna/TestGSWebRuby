class QueueDaemonBenchmark
  # CREATE_BLOB_SAMPLE_DATA
  # DISABLE_BLOB_SAMPLE_DATA
  UPDATE_BLOB_SAMPLE_DATA = {
    Enrollment: {
      entity_type: :school,
      entity_id: 23,
      entity_state: 'AK',
      member_id: 3,
      value: 34
    },
    Ethnicity: {
      entity_type: :school,
      entity_id: 23,
      entity_state: 'AK',
      member_id: 4,
      breakdown: 'Hispanic',
      value: 66
    },
    boys_sports: {
      entity_type: :school,
      entity_id: 12,
      entity_state: 'AK',
      member_id: 5,
      value: 'swimming'
    }
  }

  #Change to read from conf file eventually to get instance variables
  def initialize
    @update_queue_records = []
    @executed_actions = {update: 0, create: 0, disable: 0}
    @max_rows = 100
    @interval = 10
    #maybe eventually change to number of create, update, disable actions instead of row count so:
    #create_rows = 6
    #update_rows = 3
    #disable_rows = 1
    #for now, max_rows will only do update rows

    #number of updates in blob for each type
    @enrollment_blob_count = 2
    @ethnicity_blob_count = 2
    @boys_sports_blob_count = 2

    @queue_daemon = QueueDaemon.new
    @file_name = 'queue_daemon_benchmark_results.csv'
  end


  def start_benchmark!
    UpdateQueue.destroy_all

    results = (@max_rows/@interval).times.map do | i |
      row_count = (i + 1) * @interval
      create_update_queue_records!
      puts "#{row_count} rows created"

      time = time_queue_daemon!

      UpdateQueue.destroy_all

      process_result(time, row_count)
    end

    write_out_results(results)

    @update_queue_records = []
    @executed_actions = {update: 0, create: 0, disable: 0}
  end

  def create_update_queue_records!
    @interval.times { new_record! }

    @update_queue_records.each do |record|
      UpdateQueue.create!(record)
    end
  end

  def new_record!
    #later insert logic to create different types and return different types: update, disable, create
    @update_queue_records << new_update_queue_record
    @executed_actions[:update] = @executed_actions[:update] + 1
  end

  def new_update_queue_record
    json_blob = {
      Enrollment: update_enrollment_data,
      Ethnicity: update_ethnicity_data,
      boys_sports: update_boys_sports_data
    }

    {
      # source: "Queue Daemon Test",
      source: "osp",
      update_blob: json_blob.to_json
    }
  end

  #this method needs to be changed in order to support customizing attirbutes ie action(update, disable, create), entity_type, etc...
  def update_enrollment_data
    @update_enrollment_data ||= @enrollment_blob_count.times.map do
      UPDATE_BLOB_SAMPLE_DATA[:Enrollment]
    end
  end

  def update_ethnicity_data
    @update_ethnicity_data ||= @ethnicity_blob_count.times.map do
      UPDATE_BLOB_SAMPLE_DATA[:Ethnicity]
    end
  end

  def update_boys_sports_data
    @update_boys_sports_data ||= @boys_sports_blob_count.times.map do
      UPDATE_BLOB_SAMPLE_DATA[:boys_sports]
    end
  end

  def time_queue_daemon!
    #Not sure if we want to use realtime vs cpu time vs system time.
    Benchmark.realtime do
      @queue_daemon.process_unprocessed_updates
    end
  end

  def process_result(time, row_count)
    {
      row_count: row_count,
      time: time,
      update_count: @executed_actions[:update],
      disable_count: @executed_actions[:disable],
      create_count: @executed_actions[:create],
      enrollment: @enrollment_blob_count,
      ethnicity: @enrollment_blob_count,
      boys_sports: @boys_sports_blob_count
    }
  end

  def write_out_results(results)
    output_values = [:row_count,:time,:update_count,:disable_count,:create_count,:enrollment,:ethnicity,:boys_sports]
    output = output_values.join(',') + "\n"

    results.each do |result|
      row = output_values.map { |v| result[v] }.join(',') + "\n"
      output << row
    end

    f_name = Time.now.to_i.to_s + @file_name
    File.write(f_name, output)
  end

end

if Rails.env == 'test'
  QueueDaemonBenchmark.new.start_benchmark!
end
