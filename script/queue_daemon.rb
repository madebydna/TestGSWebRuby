# Sample queue daemon

# AC:
# 1. Constants can be created and reused
# 2. The pid of the process is known for easy process killing if necessary (See stop_daemon.sh)
# 3. Has access to all our favorite GSWebRuby data objects
# 4. Can log to the standard logs (or probably could make our own log too)
# 5. It can run forever, at some interval that we specify
# 6. Rails server process is not killed. (Trivial, but important)

# [From GSWebRuby root]
# To run:
#   rails runner script/queue_daemon.rb
# To view that the log is successfully fighting off the Balrog:
#   tail -f log/development.log
# To see that it logged its process id:
#   ps -a | grep [q]ueue_daemon
#   cat log/queue_daemon_pid
# To use the kill switch:
#   script/stop_queue_daemon.sh

def all_census_data_types
  @all_census_data_type_names ||= Hash[CensusDataType.all.map { |cdt| [cdt.description, cdt.id] }]
end

def census_data_type?(datatype)
  all_census_data_types.key? datatype
end

def process_data_as_census(update_blob)
  # data_type_id = all_census_data_types[]
  puts __method__
end

def process_data_as_osp(update_blob)
  puts __method__
end

def print_all_unprocessed_updates
  updates = UpdateQueue.todo
  updates.each do |update|
    update_blob = JSON.parse(update.update_blob)
    puts update_blob
    data_types = update_blob.keys
    data_types.each do |data_type|
      puts data_type
      census_or_osp = census_data_type?(data_type) ? :census : :osp
      send('process_data_as_' + census_or_osp.to_s, update_blob[data_type])
    end
  end
end

def log_pid
  pid_file = File.open('log/queue_daemon_pid', 'w')
  pid_file.write $PID
  pid_file.close
end

log_pid ### 2. ###

UpdateQueue.seed_sample_data!

loop do
  print_all_unprocessed_updates
  # Rails.logger.error 'You shall not pass!' ### 4. ###
  sleep 2 ### 5. ###
end