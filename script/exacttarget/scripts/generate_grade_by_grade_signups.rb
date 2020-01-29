require_relative '../exacttarget_config/exacttarget_constants'
require_relative '../exacttarget_helpers/exacttarget_sftp'
require_relative '../exacttarget_helpers/exacttarget_zip'
require_relative '../exacttarget_builders/grade_by_grade_data_extension/data_reader'
require_relative '../exacttarget_builders/grade_by_grade_data_extension/csv_writer'

# run it locally
# bundle exec rails runner script/exacttarget/exacttarget_scripts/generate_grade_by_grade_signups.rb
writer = Exacttarget::GradeByGradeDataExtension::CsvWriter.new
writer.write_file # should output to /tmp/et_grade_by_grade_signups.csv
writer.zip_file
writer.upload_file