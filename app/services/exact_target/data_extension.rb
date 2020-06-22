class ExactTarget
  class DataExtension
    EXTENSIONS_TO_KEYS = {
      'gbg_subscriptions' => '860393D2-0BB1-412A-88D8-78A8373C1746',
      'gs_school' => '1181AE14-B381-4714-8E9B-AC813E485C11',
      'school_sign_up' => '59BDA5B9-A70F-42F7-BA9E-45E2963237F6',
      'subscription_list' => 'F74023BB-90B7-4BE6-A506-58ED8F3516B6'
    }

    def self.upsert(object)
      method = get_method_from_object(object)
      Rest.perform_call(method, object)
    end

    def self.delete(object)
      key = get_key_from_object(object)
      Soap.perform_call(:delete, key, object)
    end

    def self.get_method_from_object(object)
      case object
      when School
        :upsert_school
      when StudentGradeLevel
        :upsert_gbg
      when SchoolUser
        :upsert_school_signup
      when Subscription
        :upsert_subscription
      else
        raise ArgumentError, "#{object.class} does not have a matching ExactTarget DataExtension"
      end
    end

    def self.get_key_from_object(object)
      case object
      when School
        EXTENSIONS_TO_KEYS['gs_school']
      when StudentGradeLevel
        EXTENSIONS_TO_KEYS['gbg_subscriptions']
      when SchoolUser
        EXTENSIONS_TO_KEYS['school_sign_up']
      when Subscription
        EXTENSIONS_TO_KEYS['subscription_list']
      else
        raise ArgumentError, "#{object.class} does not have a matching ExactTarget DataExtension"
      end
    end
  end
end