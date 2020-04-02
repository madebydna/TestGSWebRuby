module ExactTargetFileManager
  module Builders
    module DistrictDataExtension
      class CsvWriter < ExactTargetFileManager::Builders::EtProcessor
        FILE_PATH = '/tmp/et_districts.csv'

        # District data extension addition. district_id, district_state, district_name - there are more possible fields
        # Add: District contact official name, email
        # Add: District % above/at/below avg Summary Rating + state averages
        # ==> Add: District college success data types <== WHICH ONES??
        # Add: District progress %below, avg, above + state averages
        # Add: District average revenue & spending per student + state averages
        # Add: District logo

        HEADERS = %w(
          id
          district_id
          state
          name
          official_email
          official_name
          district_summary_below_average
          state_summary_below_average
          district_summary_average
          state_summary_average
          district_summary_above_average
          state_summary_above_average
          district_progress_below_average
          state_progress_below_average
          district_progress_average
          state_progress_average
          district_progress_above_average
          state_progress_above_average
          district_average_revenue_per_student
          state_average_revenue_per_student
          district_average_spending_per_student
          state_average_spending_per_student
        )

        def initialize
          @data_reader = DataReader.new
        end

        def write_file
          CSV.open(FILE_PATH, 'w') do |csv|
            csv << HEADERS
            @data_reader.each_district { |district| csv << get_info(district) }
          end
        end

        def get_info(district)
          district_info = []
          district_info << district.unique_id
          district_info << district.district_id
          district_info << district.state
          district_info << district.name
          district_info << district.head_official_name
          district_info << district.head_official_email
          district_info += add_summary_rating_info(district.summary_rating_info)
          district_info += add_progress_rating_info(district.growth_rating_info)
          district_info += add_finance_info(district.finance_info)
          district_info
        end

        def add_summary_rating_info(data)
          return ([nil] * 6) unless data.present?
          [
           data.dig("district", "below_average"),
           data.dig("state", "below_average"),
           data.dig("district", "average"),
           data.dig("state", "average"),
           data.dig("district", "above_average"),
           data.dig("state", "above_average")
          ]
        end

        def add_progress_rating_info(data)
          return ([nil] * 6) unless data.present?
          [
           data.dig("district", "below_average"),
           data.dig("state", "below_average"),
           data.dig("district", "average"),
           data.dig("state", "average"),
           data.dig("district", "above_average"),
           data.dig("state", "above_average")
          ]
        end

        def add_finance_info(data)
          return ([nil] * 4) unless data.present?
          [
            data.dig("district", "Per Pupil Revenue"),
            data.dig("state", "Per Pupil Revenue"),
            data.dig("district", "Per Pupil Expenditures"),
            data.dig("state", "Per Pupil Expenditures")
           ]
        end

      end
    end
  end
end
