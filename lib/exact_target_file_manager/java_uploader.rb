# frozen_string_literal: true
require 'stringio'

module ExactTargetFileManager
  class JavaUploader
    def self.upload
      log = ScriptLogger.record_log_instance(et_process_to_run: 'java_upload') rescue nil
      begin
        file = '/usr2/local/batch/output/exacttarget/members.total.zip.gpg'
        open(file) do |io|
          ExactTargetFileManager::Helpers::SFTP.upload(io)
        end
        log.finish_logging_session(1, "SUCCESS: completed uploading legacy Java members file: #{file}") rescue nil
      rescue StandardError => e
        puts e.message          # Human readable error
        log.finish_logging_session(0, "ERROR: Java upload process failed, key: java_upload, error: #{e.message}") rescue nil
        exit 1
      end
    end
  end
end