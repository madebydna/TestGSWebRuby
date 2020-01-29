process_to_run = ARGV.first



if VALID_ET_PARAMETERS.include?(process_to_run)
  run
else
  puts "XXXXX"
end

def run
  # map_class = MAPPING_CLASSES[process_to_run.to_sym]
  writer = Exacttarget::Builders::MAPPING_CLASSES[process_to_run.to_sym]::CsvWriterComponent.new
  writer.write_file # should output to /tmp/et_grade_by_grade_signups.csv
  validator = writer.validate_file
  if validator.valid?
    writer.zip_file
    writer.upload_file
  else
    # validator.errors
    put 'errors!!!'
  end

end
