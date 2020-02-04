process_to_run = ARGV.first

if VALID_ET_PARAMETERS.include?(process_to_run)
  run
else
  puts "'#{process_to_run}' is not a valid ExactTarget parameter."
end

# TODO: Account for 'unsubscribes' which only has a processor file and 'all'
def run
  # map_class = MAPPING_CLASSES[process_to_run.to_sym]
  writer = Exacttarget::Builders::MAPPING_CLASSES[process_to_run.to_sym]::CsvWriterComponent.new
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
