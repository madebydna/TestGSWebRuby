require_relative '../exacttarget_config/exacttarget_constants'
require_relative '../exacttarget_helpers/exacttarget_sftp'
require_relative '../exacttarget_helpers/exacttarget_zip'
require_relative '../exacttarget_builders/unsubscribes_processor'

processor = Exacttarget::UnsubscribesProcessor.new
processor.download_file
processor.run