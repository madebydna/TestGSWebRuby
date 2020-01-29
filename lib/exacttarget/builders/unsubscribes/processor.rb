module Exacttarget
  module Builders
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
          # Awkward file reading necessary because ET has funny encoding and line breaks
          file = File.read("/tmp/#{@file_name}").force_encoding('UTF-16LE').encode!('UTF-8')
          file.split("\r\n").each_with_index do |line, i|
            next if i == 0
            et_id, date_unsubscribed, email, status = line.chomp.split(",")
            user = User.find_by(email: email)
            UserSubscriptionManager.new(user).unsubscribe
          end
        end
      end
    end
  end
end