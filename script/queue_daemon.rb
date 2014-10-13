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

def abbrevs
  @abbrevs ||= States.abbreviations ### 1. ###
end

def print_first_school_of_random_state
  state = abbrevs.sample
  school = School.on_db(state.to_sym).where(active: true).first ### 3. ###
  puts "Using #{state}"
  puts 'First school:'
  puts "\t\t#{school.id}"
  puts "\t\t#{school.name}"
end

def log_pid
  pid_file = File.open('log/queue_daemon_pid', 'w')
  pid_file.write $PID
  pid_file.close
end

log_pid ### 2. ###

loop do
  print_first_school_of_random_state
  Rails.logger.error 'You shall not pass!' ### 4. ###
  sleep 2 ### 5. ###
end