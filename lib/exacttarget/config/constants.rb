module Exacttarget
  module Config
    module Constants
      VALID_ET_PARAMETERS = %w(all grade_by_grade school_list member_list list_signups unsubscribes school_signups)

      MAPPING_CLASSES = {
          grade_by_grade: GradeByGradeDataExtension
      }
    end
  end
end
