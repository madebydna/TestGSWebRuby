module ExactTargetFileManager
  module Config
    module Constants
      VALID_ET_PARAMETERS = %w(all grade_by_grade school_list district_list member_list member_list_de list_signups unsubscribes school_signups spanish_unsubscribes spanish_signups java_upload)

      MAPPING_CLASSES_DOWNLOADS_ALL = {
          spanish_signups: 'EtSpanishGbyg::SpanishSubscriptionProcessor',
          unsubscribes: 'Unsubscribes::Processor',
          spanish_unsubscribes: 'EtSpanishGbyg::SpanishUnsubscribeProcessor',
      }

      MAPPING_CLASSES_DOWNLOADS = {
          unsubscribes: 'Unsubscribes::Processor',
      }

      MAPPING_CLASSES_UPLOADS = {
          grade_by_grade: GradeByGradeDataExtension,
          list_signups: SubscriptionListDataExtension,
          member_list: AllSubscribers,
          member_list_de: MemberDataExtension,
          school_list: SchoolDataExtension,
          district_list: DistrictDataExtension,
          school_signups: SchoolSignupDataExtension,
      }
    end
  end
end
