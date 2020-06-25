process_to_run = ARGV.first

class ExactTargetJobs
  include ExactTargetFileManager::Config::Constants

  def initialize(process_to_run)
    @process_to_run = process_to_run
    if VALID_ET_PARAMETERS.exclude?(process_to_run)
      puts "'#{process_to_run}' is not a valid ExactTargetFileManager parameter."
      puts "The possible parameters are: #{VALID_ET_PARAMETERS.join(', ')}"
      exit 1
    end
  end

  def run
    ptr = @process_to_run.to_sym
    upload_class = MAPPING_CLASSES_UPLOADS[ptr]
    download_class = MAPPING_CLASSES_DOWNLOADS_ALL[ptr]
    if ptr == :all
      MAPPING_CLASSES_DOWNLOADS.each { |key, _| download_import(key) }
      MAPPING_CLASSES_UPLOADS.each { |key, _| build_zip_upload(key) }
    elsif ptr == :java_upload
      ExactTargetFileManager::JavaUploader.upload
    elsif upload_class
      build_zip_upload(ptr)
    elsif download_class
      download_import(ptr)
    end
  end

  def download_import(key)
    begin
      log = ScriptLogger.record_log_instance(et_process_to_run: key) rescue nil
      processor_string = "ExactTargetFileManager::Builders::#{MAPPING_CLASSES_DOWNLOADS_ALL[key]}"
      processor = processor_string.constantize.new
      puts "Working on: #{key}"
      print "...downloading..."
      processor.download_file
      print "...running..."
      processor.run
      puts "success"
      log.finish_logging_session(1, "SUCCESS: completed uploading ET processing key: #{key}") rescue nil
    rescue StandardError => e
      puts e.message          # Human readable error
      log.finish_logging_session(0, "ERROR: download import process failed, key: #{key}, error: #{e.message}") rescue nil
      exit 1
    end
  end

  def validate_file(writer, log)
    print "validating..."
    validator = writer.validate_file
    if validator.valid?
      return true
    else
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

  def build_zip_upload(key)
    log = ScriptLogger.record_log_instance(et_process_to_run: key) rescue nil
    begin
      writer_string = "ExactTargetFileManager::Builders::#{MAPPING_CLASSES_UPLOADS[key]}::CsvWriter"
      writer = writer_string.constantize.new
      puts "Working on: #{MAPPING_CLASSES_UPLOADS[key]}"
      print "...writing..."
      writer.write_file
      if validate_file(writer, log)
        zip_and_upload(writer)
        puts "success"
        log.finish_logging_session(1, "SUCCESS: completed uploading ET processing key: #{key}") rescue nil
      end
    rescue StandardError => e
      puts e.message          # Human readable error
      log.finish_logging_session(0, "ERROR: build upload process failed, key: #{key}, error: #{e.message}") rescue nil
      exit 1
    end
  end
end

ExactTargetJobs.new(process_to_run).run
