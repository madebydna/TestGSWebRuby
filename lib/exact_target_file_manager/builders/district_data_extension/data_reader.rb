module ExactTargetFileManager
  module Builders
    module DistrictDataExtension
      class DataReader

        def each_district
          DistrictRecord.active.find_each do |district|
            yield DistrictDecorator.new(district)
          end
        end

      end
    end
  end
end