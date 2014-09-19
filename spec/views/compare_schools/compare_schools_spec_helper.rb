require 'spec_helper'
require_relative '../../libs/school_cache/school_cache_helper'

module CompareSchoolsSpecHelper
  include SchoolCacheHelper

  def create_set_of_school_caches!
    create_school_cache_set_in_db!(1, :ca)
    create_school_cache_set_in_db!(2, :ca)
    create_school_cache_set_in_db!(3, :ca)
  end

  #long descriptions for school name, ethnic breakdown, grade levels
  def create_school_cache_data_with_long_ethnicity!(school)
    create_school_cache_set_in_db!(school.id, school.shard) do |char, rev, esp, rat|
      char["Ethnicity"] << {"year"=>2014, "source"=>"DE Dept. of Education", "breakdown"=>"Hawaiian Native/Pacific Islander", "state_average"=>0.0}
    end
  end

  def create_school_cache_data_with_long_enrollment!(school)
    create_school_cache_set_in_db!(school.id, school.shard) do |char, rev, esp, rat|
      char["Enrollment"][0] = {"year"=>2014, "source"=>"DE Dept. of Education", "school_value"=>30000.0}
    end
  end

  def create_school_cache_data_with_no_ethnicity_data!(school)
    create_school_cache_set_in_db!(school.id, school.shard) do |char, rev, esp, rat|
      char.delete('Ethnicity')
    end
  end

  def create_set_of_aligned_schools!
    FactoryGirl.create(:school, :with_levels, id: 1, state: :ca)
    FactoryGirl.create(:school, :with_levels, id: 2, state: :ca)
    FactoryGirl.create(:school, :with_levels, id: 3, state: :ca)
  end

  def school_ids_displayed_on_map
    page.evaluate_script("GS.search.mapMarkers.map(function(x) {if(x.map){return x.schoolId;} })")
  end

  # def decorate_schools(schools, cache_data)
  #   decorated_schools = []
  #   db_schools = schools
  #   db_schools.each do |db_school|
  #     if decorated_schools.size < 4
  #       decorated_schools << SchoolCompareDecorator.new(db_school, context: cache_data[db_school.id.to_i])
  #     end
  #   end
  #   decorated_schools
  # end

end