module ExactTargetFileManager
  module Builders
    module SchoolDataExtension
      class DataReader

        def each_school
          States::STATE_HASH.values.uniq.each do |state|
            puts "Current state: #{state}"
            School.on_db(state.downcase.to_sym).active.order(:id).not_preschool_only.each do |school|
              yield school
            end
          end
        end

        def school_cache_data_reader(school)
          SchoolProfiles::SchoolCacheDataReader.new(school)
        end

        def test_scores(school, school_cache_data_reader)
          SchoolProfiles::TestScores.new(
              school,
              school_cache_data_reader: school_cache_data_reader
          )
        end

      end
    end
  end
end
