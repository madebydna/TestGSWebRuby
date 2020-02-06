process_to_run = ARGV.first

class ExacttargetJobs
  include Exacttarget::Config::Constants

  def initialize(process_to_run)
    @process_to_run = process_to_run
  end

  def run
    ptr = @process_to_run.to_sym
    map_class = MAPPING_CLASSES[ptr]
    if ptr == :all
      MAPPING_CLASSES.each {| key, _ | write_to_file(key)}
      unsubscribe_run
    elsif map_class
      write_to_file(ptr)
    else
      unsubscribe_run
    end
  end

  def unsubscribe_run
    processor = Exacttarget::Builders::Unsubscribes::Processor.new
    puts "Working on: Unsubscribes"
    print "...downloading..."
    processor.download_file
    print "...running..."
    processor.run
    puts "success"
  end

  def write_to_file(key)
    writer_string = "Exacttarget::Builders::#{MAPPING_CLASSES[key]}::CsvWriterComponent"
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
    else
      # validator.errors
      puts 'ERROR: Invalid file.'
      puts validator.errors
    end
  end
end

if Exacttarget::Config::Constants::VALID_ET_PARAMETERS.include?(process_to_run)
  ExacttargetJobs.new(process_to_run).run
else
  puts "'#{process_to_run}' is not a valid ExactTarget parameter."
end