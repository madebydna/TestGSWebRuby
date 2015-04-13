require 'spec_helper'

# In tests that calls this context you need to clean whatever db shard you used
shared_context 'then run the queue daemon' do | *dbs_to_clean |
  #buffers before block execution, so that queue daemon will get run
  #this forces the before block to wait until current_url can get run, which is after all requests have finished
  #otherwise, queue daemon will get run too early before the requests finishes and data is in the update_queue table
  before { current_url }
  before do
    q = QueueDaemon.new
    q.process_unprocessed_updates
  end

  after do
    dtc = dbs_to_clean | [:gs_schooldb]
    clean_dbs *dtc
  end
end

#this is asynchronous so the timing of results getting processed will vary and is not buffered
shared_context 'Start the Queue Daemon Process' do | *dbs_to_clean |
  pid = 0

  before do
    q = QueueDaemon.new
    pid = fork do
      q.run!
    end
  end

  after do
    Process.kill("HUP", pid)
  end

  after do
    dtc = dbs_to_clean | [:gs_schooldb]
    clean_dbs *dtc
  end
end
