# frozen_string_literal: true

require ' ../../../..//lib/school_profiles/school_cache_data_reader'

module Exacttarget
  module SchoolDataExtension
    class DataReader

      def each_school
        State.all.pluck('state').each do |state|
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
