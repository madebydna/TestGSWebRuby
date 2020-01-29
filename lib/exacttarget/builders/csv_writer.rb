# frozen_string_literal: true

require 'csv'
require 'csvlint'
# require_relative '../helpers/sftp'
# require_relative '../helpers/zip'

module Exacttarget
  module Builders
    class CsvWriter

      def file_path
        puts "Not Me"
      end
      def zip_file
        Exacttarget::Helpers::EtZip.new.zip(file_path)
      end

      def upload_file
        Exacttarget::Helpers::SFTP.new.upload("#{file_path}.zip")
      end

      def validate_file
        validator = Csvlint::Validator.new(file_path)
        validator.validate
        validator
      end

    end
  end
end