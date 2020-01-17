require_relative '../exacttarget_config/exacttarget_constants'
require_relative '../exacttarget_builders/school_signup_data_extension/data_reader'
require_relative '../exacttarget_builders/school_signup_data_extension/csv_writer'

writer = Exacttarget::SchoolSignupDataExtension::CsvWriter.new
writer.write_file # should output to /tmp/et_school_signups.csv