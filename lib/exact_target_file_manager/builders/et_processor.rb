# frozen_string_literal: true

require 'csv'
require 'csvlint'

module ExactTargetFileManager
  module Builders
    class EtProcessor

      def zip_file
        ExactTargetFileManager::Helpers::EtZip.new.zip(self.class::FILE_PATH)
      end

      def upload_file
        ExactTargetFileManager::Helpers::SFTP.new.upload("#{self.class::FILE_PATH}.zip")
      end

      def validate_file
        validator = Csvlint::Validator.new(self.class::FILE_PATH)
        validator.validate
        validator
      end

      def write_file
        raise NotImplementedError.new("#write_file must be defined in the CsvWriterComponent class")
      end

    end
  end
end