module ExactTargetFileManager
  module Builders
    module DistrictDataExtension
      class DistrictDecorator < SimpleDelegator
        CACHE_KEYS = %w(district_characteristics gsdata)

        def head_official_name
          cache_values['Head official name']&.first.try(:[], "district_value")
        end

        def head_official_email
          cache_values['Head official email']&.first.try(:[], "district_value")
        end

        def summary_rating_info
          @summary_rating_info ||= get_ratings_for_district_and_state('summary_rating')
        end

        def growth_rating_info
          @growth_rating_info ||= begin
            growth_type = state_cache_data["growth_type"]
            return {} if growth_type.blank? || growth_type == "N/A"
            growth_type == "Academic Progress Rating" ? academic_progress : student_progress
          end
        end

        def finance_info
          per_pupil_revenue = cache_values['Per Pupil Revenue']&.first
          per_pupil_expenditures = cache_values['Per Pupil Expenditures']&.first
          hash = {}
          if per_pupil_revenue.present?
            hash["district"] = {
              'Per Pupil Revenue' => per_pupil_revenue["district_value"],
              'Per Pupil Expenditures' => per_pupil_expenditures["district_value"]
            }
          end
          if per_pupil_expenditures.present?
            hash["state"] = {
              'Per Pupil Revenue' => per_pupil_revenue["state_value"],
              'Per Pupil Expenditures' => per_pupil_expenditures["state_value"]
            }
          end
          hash
        end

        private

        def cache_values
          @cache_values ||= begin
            DistrictCache.
            for_district(self).
            include_cache_keys(CACHE_KEYS).
            inject({}) do |hash, dc|
              hash.merge(dc.cache_data)
            end
          end
        end

        def state_cache_data
          @state_cache_data ||= begin
            StateCache.for_state('state_attributes', self.state).try(:cache_data) || {}
          end
        end

        def district_facet_results
          @district_facet_results ||= Search::SolrSchoolQuery.new(
            state: self.state,
            district_id: self.district_id,
            district_name: self.name,
            limit: 0
          ).response.facet_fields
        end

        def state_facet_results
          @state_facet_results ||= Search::SolrSchoolQuery.new(
            state: self.state,
            limit: 0
          ).response.facet_fields
        end

        def academic_progress
          @academic_progress ||= get_ratings_for_district_and_state('academic_progress_rating')
        end

        def student_progress
          @student_progress ||= get_ratings_for_district_and_state('student_progress_rating')
        end

        def get_ratings_for_district_and_state(key)
          district_data = district_facet_results.fetch(key, {})
          state_data = state_facet_results.fetch(key, {})
          {
            "district" => get_ratings_narration(district_data),
            "state" => get_ratings_narration(state_data)
          }
        end

        def get_ratings_narration(hash)
          CommunityProfiles::RatingsNarration.new(hash).ratings_percentage_hash
        end
      end
    end
  end
end