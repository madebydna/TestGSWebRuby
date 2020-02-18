process_to_run = ARGV.first

class ExactTargetJobs
  include ExactTargetFileManager::Config::Constants

  def initialize(process_to_run)
    @process_to_run = process_to_run
    if VALID_ET_PARAMETERS.exclude?(process_to_run)
      puts "'#{process_to_run}' is not a valid ExactTargetFileManager parameter."
      puts "The possible parameters are: #{ExactTargetFileManager::Config::Constants::VALID_ET_PARAMETERS.join(', ')}"
      exit 1
    end
  end


  def run
    ptr = @process_to_run.to_sym
    map_class = MAPPING_CLASSES[ptr]
    if ptr == :all
      unsubscribe_run
      MAPPING_CLASSES.each {| key, _ | write_to_file(key)}
    elsif map_class
      write_to_file(ptr)
    elsif ptr == :unsubscribes
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
    rescue StandardError => e
      puts e.message          # Human readable error
      log.finish_logging_session(0, "ERROR: unsubscribes failed, error: #{e.message}") rescue nil
      exit 1
    end
  end

  def validate_file(writer, log)
    print "validating..."
    validator = writer.validate_file
    if validator.valid?
      return true
    else
      # validator.errors
      puts 'ERROR: Invalid file.'
      puts validator.errors
      log.finish_logging_session(0, "ERROR: did not complete uploading ET processing") rescue nil4
      exit 1
    end
  end

  def zip_and_upload(writer)
    print "zipping..."
    writer.zip_file
    print "uploading..."
    writer.upload_file
  end

  def write_to_file(key)
    log = ScriptLogger.record_log_instance(et_process_to_run: key) rescue nil
    begin
      writer_string = "ExactTargetFileManager::Builders::#{MAPPING_CLASSES[key]}::CsvProcessorComponent"
      writer = writer_string.constantize.new
      puts "Working on: #{MAPPING_CLASSES[key]}"
      print "...writing..."
      writer.write_file
      if validate_file(writer, log)
        zip_and_upload(writer)
        puts "success"
        log.finish_logging_session(1, "SUCCESS: completed uploading ET processing") rescue nil
      end
    rescue StandardError => e
      puts e.message          # Human readable error
      log.finish_logging_session(0, "ERROR: unsubscribes failed, key: #{key}, error: #{e.message}") rescue nil
      exit 1
    end
  end
end

ExactTargetJobs.new(process_to_run).run
