module ExactTargetFileManager
  module Builders
    module GradeByGradeDataExtension
      class DataReader

        BATCH_SIZE = 100000

        def gbg_sign_ups
          StudentGradeLevel.all.find_in_batches(batch_size: BATCH_SIZE).with_index do |sign_ups, index|
            puts "GBG Batch number #{index+1}"
            sign_ups.each { |sign_up| yield sign_up }
          end
        end

      end
    end
  end
end