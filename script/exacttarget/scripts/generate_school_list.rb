require_relative '../exacttarget_config/exacttarget_constants'
require_relative '../exacttarget_helpers/exacttarget_sftp'
require_relative '../exacttarget_helpers/exacttarget_zip'
require_relative '../exacttarget_builders/school_data_extension/data_reader'
require_relative '../exacttarget_builders/school_data_extension/csv_writer'

# run it locally
# bundle exec rails runner script/exacttarget/exacttarget_scripts/generate_member_list.rb
writer = Exacttarget::SchoolDataExtension::CsvWriter.new
writer.write_file # should output to /tmp/et_members.csv
writer.zip_file
writer.upload_file