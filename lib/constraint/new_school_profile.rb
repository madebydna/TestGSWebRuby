module Constraint
  class NewSchoolProfile
    NEW_PROFILE_KEY = 5

    def matches?(request)
      school = school_for_request(request)
      if school.nil?
        return false
      else
        return school.for_new_profile?
      end
    end

    private

    def school_for_request(request)
      state_abbr = state_abbr(request)
      school_id = request.parameters[:schoolId]
      School.find_by_state_and_id(state_abbr, school_id)
    end

    def state_abbr(request)
      state_string = request.parameters[:state].gsub("-"," ")
      States.abbreviation(state_string)
    end
  end
end
