# frozen_string_literal: true

require 'csv'
require 'csvlint'
require_relative '../helpers/sftp'
require_relative '../helpers/zip'

module Exacttarget
  module Builders
    class CsvWriter

      def zip_file
        Zip.new.zip(FILE_PATH)
      end

      def upload_file
        SFTP.new.upload("#{FILE_PATH}.zip")
      end

      def validate_file
        validator = Csvlint::Validator.new(FILE_PATH)
        validator.validate
      end

    end
  end
end