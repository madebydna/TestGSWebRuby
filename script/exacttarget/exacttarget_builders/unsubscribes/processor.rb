require 'csv'
module Exacttarget
  module Unsubscribes
    class Processor

      attr_accessor :latest_unsubscribes

      def initialize
        @file_name = "Unsubscribes_#{Date.current.strftime('%Y-%m-%d')}.csv"
      end

      def download_file
        Exacttarget::ExacttargetSFTP.new.download("/Import/#{@file_name}")
      end

      def run
        data = CSV.read("/tmp/#{@file_name}")
        data.each do |row|
          p row
        end
      end
    end
  end
end