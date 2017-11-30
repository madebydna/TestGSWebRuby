module ActiveRecord::ConnectionAdapters
  class Mysql2Adapter
    alias_method :execute_without_retry, :execute

    def execute(*args)
      begin
        execute_without_retry(*args)
      rescue => e
        if e.message =~ /server has gone away/i || e.message =~ /Lost connection to MySQL/i
          if active?
            raise e # if the connection is still active, nothing I can do here will help. re-raise the error
          else
            GSLogger.error(:misc, e, message: 'Error executing update_queue statement', vars: {args: args.join(',')})
            reconnect!
            execute_without_retry(*args) if active?
          end
        else
          raise e
        end
      end
    end
  end
end

#Queue Daemon lives in lib/data_loading
daemon = QueueDaemon.new
daemon.run!
