process_to_run = ARGV.first

class ExactTargetJobs
  include ExactTargetFileManager::Config::Constants

  def initialize(process_to_run)
    @process_to_run = process_to_run

  end

  def run
    ptr = @process_to_run.to_sym
    map_class = MAPPING_CLASSES[ptr]
    if ptr == :all
      unsubscribe_run
      MAPPING_CLASSES.each {| key, _ | write_to_file(key)}
    elsif map_class
      write_to_file(ptr)
    else
      unsubscribe_run
    end
  end

  def unsubscribe_run
    begin
      log = ScriptLogger.record_log_instance(et_process_to_run: 'unsubscribe') rescue nil
      processor = ExactTargetFileManager::Builders::Unsubscribes::Processor.new
      puts "Working on: Unsubscribes"
      print "...downloading..."
      processor.download_file
      print "...running..."
      processor.run
      puts "success"
      log.finish_logging_session(1, "Success: completed downloading Unsubscribes and updating") rescue nil
    rescue Exception => e
      puts e.message          # Human readable error
      log.finish_logging_session(0, "ERROR: unsubscribes failed, error: #{e.message}") rescue nil
    end
  end

  def write_to_file(key)
    log = ScriptLogger.record_log_instance(et_process_to_run: key) rescue nil
    begin
      writer_string = "ExactTargetFileManager::Builders::#{MAPPING_CLASSES[key]}::CsvProcessorComponent"
      writer = writer_string.constantize.new
      puts "Working on: #{MAPPING_CLASSES[key]}"
      print "...writing..."
      writer.write_file
      print "validating..."
      validator = writer.validate_file
      if validator.valid?
        print "zipping..."
        writer.zip_file
        print "uploading..."
        writer.upload_file
        puts "success"
        log.finish_logging_session(1, "SUCCESS: completed uploading ET processing") rescue nil
      else
        # validator.errors
        puts 'ERROR: Invalid file.'
        puts validator.errors
        log.finish_logging_session(0, "ERROR: did not complete uploading ET processing") rescue nil
      end
    rescue Exception => e
      puts e.message          # Human readable error
      log.finish_logging_session(0, "ERROR: unsubscribes failed, key: #{key}, error: #{e.message}") rescue nil
    end
  end
end

if ExactTargetFileManager::Config::Constants::VALID_ET_PARAMETERS.include?(process_to_run)
  ExactTargetJobs.new(process_to_run).run
else
  puts "'#{process_to_run}' is not a valid ExactTargetFileManager parameter."
  puts "The possible parameters are: #{ExactTargetFileManager::Config::Constants::VALID_ET_PARAMETERS.join(', ')}"
end