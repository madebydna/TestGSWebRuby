# frozen_string_literal: true

module Exacttarget
  module AllSubscribers
    class DataReader

      BATCH_SIZE = 100000

      def each_updated_user
        User.where('updated > ?', 60.days.ago).each do |user|
          yield user
        end
      end

      def each_user
        User.all.find_in_batches(batch_size: BATCH_SIZE).with_index do |users, index|
          puts "Working on: #{(index+1) * BATCH_SIZE}"
          users.each { |user| yield user }
        end
      end

    end
  end
end
