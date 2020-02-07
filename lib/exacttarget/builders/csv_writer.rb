# frozen_string_literal: true

require 'csv'
require 'csvlint'

module Exacttarget
  module Builders
    class CsvWriter

      def zip_file
        Exacttarget::Helpers::EtZip.new.zip(self.class::FILE_PATH)
      end

      def upload_file
        Exacttarget::Helpers::SFTP.new.upload("#{self.class::FILE_PATH}.zip")
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