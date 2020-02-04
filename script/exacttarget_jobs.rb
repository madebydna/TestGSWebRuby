process_to_run = ARGV.first

if VALID_ET_PARAMETERS.include?(process_to_run)
  run
else
  puts "'#{process_to_run}' is not a valid ExactTarget parameter."
end

# TODO: Account for 'unsubscribes' which only has a processor file and 'all'
def run
  ptr = process_to_run.to_sym
  map_class = MAPPING_CLASSES[ptr]
  if ptr == :all
    MAPPING_CLASSES.each {| key, _ | write_to_file(key)}
    unsubscribe_run
  elsif map_class
   write(map_class)
  else
    unsubscribe_run
  end
end

def unsubscribe_run
  processor = Exacttarget::Unsubscribes::Processor.new
  processor.download_file
  processor.run
end

def write_to_file(key)
  writer = Exacttarget::Builders::MAPPING_CLASSES[key]::CsvWriterComponent.new
  writer.write_file
  validator = writer.validate_file
  if validator.valid?
    writer.zip_file
    writer.upload_file
  else
    # validator.errors
    puts 'ERROR: Invalid file.'
    puts validator.errors
  end
end
