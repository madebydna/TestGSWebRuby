# frozen_string_literal: true

class GsdataLoading::Loader < GsdataLoading::Base
  DATA_TYPE = :gsdata

  def load!
    updates.each do |update|
      next if update.blank?
      @update = GsdataLoading::Update.new(update)

      school, district = nil
      if @update.entity_level == 'school'
        school = School.on_db(@update.state_db).find_by(state_id: @update.school_id)
      elsif @update.entity_level == 'district'
        district = District.on_db(@update.state_db).find_by(state_id: @update.district_id)
      end

      if @update.action.nil? || @update.action == ACTION_NO_CACHE_BUILD
        @update.create( school, district )
      elsif @update.action == ACTION_BUILD_CACHE
        Cacher.create_caches_for_data_type(school, DATA_TYPE)
      end
    end
  end


  # decide what to do with dups, where they are detected and if they are what is the result

  # def check_dup
  #   # school_id, state, grade, breakdown, academic, source_id? source_valid?
  #   # join datavalue to academics map and breakdown map and source?
  #   nil
  # end
end
# {"test_scores":[{"action": "no_cache_rebuild", "value":1.79,"state":"ms","entity_level":"school","state_id":"4820004","district_id":"4820","data_type_id":323,"subject_id":4,"proficiency_band_id":115,"cohort_count":"null","grade":"3","active":1,"academics":[{"id":1,"name":"All Students"}],"breakdowns":[{"id":1,"name":"All Students"}],"source":{"source_name":"GreatSchools","date_valid":"2017-08-14 11:31:39","notes":"DXT-2168 MS 2016 MAP EOC test load"},"year":2016}]}