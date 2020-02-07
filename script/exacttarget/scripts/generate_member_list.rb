require_relative '../config/constants'
require_relative '../helpers/sftp'
require_relative '../helpers/zip'

# run it locally
# bundle exec rails runner script/exacttarget/exacttarget_scripts/generate_member_list.rb
writer = Exacttarget::AllSubscribers::CsvWriter.new
writer.write_file # should output to /tmp/et_members.csv
writer.zip_file
writer.upload_file