# frozen_string_literal: true

module ExactTargetFileManager
  module Builders
    module SchoolDataExtension
      class CsvProcessorComponent < ExactTargetFileManager::Builders::EtProcessor

        FILE_PATH = '/tmp/et_schools.csv'
        HEADERS = %w(
                    id
                    school_id
                    school_type
                    level_code
                    state
                    name
                    city
                    zip_code
                    district_id
                    canonical_url
                    Summary_Rating
                    Advanced_Course_Rating
                    Test_Score_Rating
                    College_Readiness_Rating
                    Student_Progress_Rating
                    Equity_Rating
                    Academic_Progress_Rating
                    CSA_Badge
                    Ratio_of_students_to_full_time_teachers
                    Ratio_of_students_to_full_time_counselors
                    Percentage_of_teachers_with_three_or_more_years_experience
                    Percentage_of_full_time_teachers_who_are_certified
                    Discipline_Flag
                    Attendance_Flag
                    English_Test_Score
                    Math_Test_Score
                  )
        GSDATA_CONTENT =   ['Ratio of students to full time teachers',
                            'Ratio of students to full time counselors',
                            'Percentage of teachers with less than three years experience',
                            'Percentage of full time teachers who are certified']

        def initialize
          @data_reader = DataReader.new
        end

        def write_file
          CSV.open(FILE_PATH, 'w') do |csv|
            csv << HEADERS
            @data_reader.each_school { |school| csv << get_info(school) if school.present?}
          end
        end

        def get_info(school)
          school_cache_data_reader = @data_reader.school_cache_data_reader(school)
          gsdata_info = school_cache_data_reader.decorated_gsdata_datas(*GSDATA_CONTENT)
          test_scores = @data_reader.test_scores(school, school_cache_data_reader)
          school_info = []
          school_info << school['state'] + "-" + school['id'].to_s
          school_info << school['id']
          school_info << school['type']
          school_info << school['level_code']
          school_info << school['state']
          school_info << school['name']
          school_info << school['city']
          school_info << school['zipcode']
          school_info << school['district_id']
          school_info << school['canonical_url']
          school_info << school_cache_data_reader.gs_rating ? school_cache_data_reader.gs_rating : ''
          school_info << school_cache_data_reader.advanced_courses_rating ? school_cache_data_reader.advanced_courses_rating : ''
          school_info << school_cache_data_reader.test_scores_rating ? school_cache_data_reader.test_scores_rating : ''
          school_info << school_cache_data_reader.college_readiness_rating ? school_cache_data_reader.college_readiness_rating : ''
          school_info << school_cache_data_reader.student_progress_rating ? school_cache_data_reader.student_progress_rating : ''
          school_info << school_cache_data_reader.equity_overview_rating ? school_cache_data_reader.equity_overview_rating : ''
          school_info << school_cache_data_reader.academic_progress_rating ? school_cache_data_reader.academic_progress_rating : ''
          school_info << csa_awards_years(school_cache_data_reader)
          school_info << gsdata_value(gsdata_info, GSDATA_CONTENT[0])
          school_info << gsdata_value(gsdata_info, GSDATA_CONTENT[1])
          school_info << gsdata_value_percentage_invert(gsdata_info, GSDATA_CONTENT[2])
          school_info << gsdata_value(gsdata_info, GSDATA_CONTENT[3])
          school_info << school_cache_data_reader.discipline_flag?
          school_info << school_cache_data_reader.attendance_flag?
          school_info << test_score(test_scores, 'English')
          school_info << test_score(test_scores, 'Math')
        end

        def gsdata_value(gsdata_info, key)
          if gsdata_info && gsdata_info[key].present?
            gsdata_info[key].having_most_recent_date.first.school_value_as_int
          end
        end

        def gsdata_value_percentage_invert(gsdata_info, key)
          if gsdata_info && gsdata_info[key].present?
            100 - gsdata_info[key].having_most_recent_date.first.school_value_as_int
          end
        end

        def csa_awards_years(school_cache_data_reader)
          if school_cache_data_reader.csa_awards.present?
            school_cache_data_reader.csa_awards.map { |award| Date.parse(award["source_date_valid"]).year }.join(',')
          end
        end

        def test_score(test_scores, subject)
          test_scores&.subject_scores&.select {|test| test.label==subject}&.first&.score&.format
        end

      end
    end
  end
end