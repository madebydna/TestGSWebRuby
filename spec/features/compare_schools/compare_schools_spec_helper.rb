require 'spec_helper'
require_relative '../../libs/school_cache/school_cache_helper'

module CompareSchoolsSpecHelper
  include SchoolCacheHelper

  #long descriptions for school name, ethnic breakdown, grade levels
  def school_cache_data_with_long_descriptions
    characteristics = characteristics do |char|
      char["characteristics"]["Ethnicity"] << {"year"=>2014, "source"=>"DE Dept. of Education", "breakdown"=>"Hawaiian Native/Pacific Islander", "state_average"=>0.0}
      char["characteristics"]["Enrollment"][0] = {"year"=>2014, "source"=>"DE Dept. of Education", "school_value"=>30000.0}
    end

    characteristics.merge(reviews_snapshot.merge(esp_responses.merge(ratings)))
  end

  def school_caches
    {
        1 => school_cache_data,
        2 => school_cache_data,
        3 => school_cache_data,
        4 => school_cache_data_with_long_descriptions
    }
  end

  def schools
    [
        FactoryGirl.build(:school, :with_levels, id: 1),
        FactoryGirl.build(:school, :with_levels, id: 2),
        FactoryGirl.build(:school, :with_levels, id: 3),
        FactoryGirl.build(:school, id: 4, level: "PK,KG,1,2,4,5,7,9,11,UG", level_code: "p,e,m,h")
    ]
  end

  def decorated_schools_mock
    decorated_schools = []
    cache_data = school_caches
    db_schools = schools
    db_schools.each do |db_school|
      if decorated_schools.size < 4
        decorated_schools << SchoolCompareDecorator.new(db_school, context: cache_data[db_school.id.to_i])
      end
    end
    decorated_schools
  end

end