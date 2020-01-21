require_relative '../exacttarget_config/exacttarget_constants'
require_relative '../exacttarget_helpers/exacttarget_sftp'
require_relative '../exacttarget_helpers/exacttarget_zip'
require_relative '../exacttarget_builders/subscription_list_data_extension/data_reader'
require_relative '../exacttarget_builders/subscription_list_data_extension/csv_writer'

writer = Exacttarget::SubscriptionListDataExtension::CsvWriter.new
writer.write_file # should output to /tmp/et_list_signups.csv
writer.zip_file
writer.upload_file