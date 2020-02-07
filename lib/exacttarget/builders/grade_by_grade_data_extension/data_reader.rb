module Exacttarget
  module Builders
    module GradeByGradeDataExtension
      class DataReader

        def gbg_signups
          StudentGradeLevel.all.each do |signup|
            yield signup
          end
        end

      end
    end
  end
end