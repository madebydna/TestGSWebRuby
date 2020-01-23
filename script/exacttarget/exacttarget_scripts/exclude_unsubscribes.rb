require_relative '../exacttarget_config/exacttarget_constants'
require_relative '../exacttarget_helpers/exacttarget_sftp'
require_relative '../exacttarget_helpers/exacttarget_zip'
require_relative '../exacttarget_builders/unsubscribes/processor'

processor = Exacttarget::Unsubscribes::Processor.new
processor.download_file
processor.run