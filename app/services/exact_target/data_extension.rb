class ExactTarget
  class DataExtension
    TYPES_TO_EXTENSIONS = {
      'subscription' => 'subscription_list',
      'school' => 'gs_school',
      'school_subscription' => 'school_sign_up',
      'grade_by_grade' => 'gbg_subscriptions',
      'member' => 'members'
    }

    EXTENSIONS_TO_KEYS = {
      'gbg_subscriptions' => '860393D2-0BB1-412A-88D8-78A8373C1746',
      'gs_school' => '1181AE14-B381-4714-8E9B-AC813E485C11',
      'school_sign_up' => '59BDA5B9-A70F-42F7-BA9E-45E2963237F6',
      'subscription_list' => 'F74023BB-90B7-4BE6-A506-58ED8F3516B6',
      'members' => '8D205751-75CD-4907-A256-E23093EFA130'
    }

    def self.upsert(type, object)
      method = get_method_from_type(type)
      Rest.perform_call(method, object)
    end

    def self.delete(type, id_or_ids)
      key = get_key_from_type(type)
      ids = Array.wrap(id_or_ids)
      Soap.perform_call(:delete, key, ids)
    end

    def self.retrieve(type, filter, properties)
      de = TYPES_TO_EXTENSIONS[type]
      raise ArgumentError, "#{type} does not have a matching ExactTarget DataExtension" unless de
      Soap.perform_call(:retrieve, de, filter, properties)
    end

    def self.get_method_from_type(type)
      case type
      when 'school'
        :upsert_school
      when 'grade_by_grade'
        :upsert_gbg
      when 'school_subscription'
        :upsert_school_signup
      when 'subscription'
        :upsert_subscription
      when 'member'
        :upsert_member
      else
        raise ArgumentError, "#{type} does not have a matching ExactTarget DataExtension"
      end
    end

    def self.get_key_from_type(type)
      extension = TYPES_TO_EXTENSIONS[type]
      raise ArgumentError, "#{type} does not have a matching ExactTarget DataExtension" unless extension
      EXTENSIONS_TO_KEYS[extension]
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
      when User
        EXTENSIONS_TO_KEYS['members']
      else
        raise ArgumentError, "#{object.class} does not have a matching ExactTarget DataExtension"
      end
    end

  end
end