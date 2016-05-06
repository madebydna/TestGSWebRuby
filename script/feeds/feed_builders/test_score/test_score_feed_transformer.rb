require_relative '../../feed_config/feed_constants'

module Feeds
  module TestScoreFeedTransformer

    include Feeds::FeedConstants

    @@proficiency_bands = Hash[TestProficiencyBand.all.map { |pb| [pb.id, pb] }]
    @@test_data_subjects = Hash[TestDataSubject.all.map { |o| [o.id, o] }]
    @@test_data_breakdowns = Hash[TestDataBreakdown.all.map { |bd| [bd.id, bd] }]
    @@test_data_breakdowns_name_mapping = Hash[TestDataBreakdown.all.map { |bd| [bd.name, bd] }]

    def transpose_state_data_for_feed(state,state_test_data)
      state_level_test_data = []
      state_test_data.each do |data|
        band = @@proficiency_bands[data["proficiency_band_id"]].present? ? @@proficiency_bands[data["proficiency_band_id"]].name : nil
        entity_level = ENTITY_TYPE_STATE
        grade = data["grade_name"]
        year = data["year"]
        level = data["level_code"]
        test_id =data["data_type_id"]
        subject = @@test_data_subjects[data.subject_id].present? ? @@test_data_subjects[data.subject_id].name : ''
        breakdown_name = @@test_data_breakdowns[data.breakdown_id].present? ? @@test_data_breakdowns[data.breakdown_id].name : ''
        breakdown_id = data["breakdown_id"]
        test_data = create_hash_for_xml(state,band, data, nil, entity_level, grade, level, subject, test_id, year, @data_type, breakdown_id,breakdown_name )
        state_level_test_data.push(test_data)
      end
      state_level_test_data
    end

    def transpose_data_for_xml(state,all_test_score_data, entity, test_id, entity_level,data_type)
      parsed_data_for_xml = []
      test_score_data = all_test_score_data.present? &&  data_type == WITH_NO_BREAKDOWN ? all_test_score_data.try(:slice,"All") : all_test_score_data
      test_score_data.try(:each) do |breakdown,breakdown_data|
        breakdown_data["grades"].try(:each) do |grade, grade_data|
          grade_data["level_code"].try(:each) do |level, subject_data|
            subject_data.try(:each) do |subject, years_data|
              years_data.try(:each) do |year, data|
                # Get Band Names from Cache
                band_names = get_band_names(data)
                # Get Data For All Bands
                band_names.try(:each) do |band|
                  test_data = create_hash_for_xml(state,band, data, entity, entity_level, grade, level, subject, test_id, year,@data_type,nil,breakdown)
                  parsed_data_for_xml.push(test_data)
                end
              end
            end
          end
        end
      end
      parsed_data_for_xml
    end

    def create_hash_for_xml(state,band, data, entity = nil, entity_level, grade, level, subject, test_id, year, data_type,breakdown_id, breakdown_name)
      test_data = {:universal_id => transpose_universal_id(state,entity, entity_level),
                   :test_id => transpose_test_id(state,test_id),
                   :entity_level => entity_level.titleize,
                   :year => year,
                   :subject_name => subject,
                   :grade_name => grade,
                   :level_code_name => level,
                   :score => transpose_test_score(band, data, entity_level),
                   :proficiency_band_id => transpose_band_id(band, data, entity_level),
                   :proficiency_band_name => transpose_band_name(band),
                   :number_tested => transpose_number_tested(data)
      }
      additional_data_for_subgroup = {:breakdown_id => transpose_breakdown_id(breakdown_id,breakdown_name,@@test_data_breakdowns_name_mapping),
                                      :breakdown_name => breakdown_name
      }
      data_type == WITH_ALL_BREAKDOWN ? test_data.merge!(additional_data_for_subgroup) : test_data
    end

    def transpose_breakdown_id(breakdown_id,breakdown_name,test_data_breakdowns)
      breakdown_name = breakdown_name == 'All' ? 'All students' : breakdown_name
      breakdown_id.present?  ?  breakdown_id : test_data_breakdowns[breakdown_name].try(:id)
    end


    def transpose_test_score(band, data,entity_level)
      if (entity_level == ENTITY_TYPE_STATE)
        data.state_value_text|| data.state_value_float
      else
        band == PROFICIENT_AND_ABOVE_BAND ?  data["score"]: data[band+"_score"]
      end
    end


    def transpose_band_name(band)
      # For proficient and above band id is always null in database
      band == nil ? PROFICIENT_AND_ABOVE_BAND:  band
    end

    def transpose_band_id(band, data, entity_level)
      # For proficient and above band id is always null in database
      if (entity_level == ENTITY_TYPE_STATE )
        band =  data["proficiency_band_id"].nil? ? '' : data["proficiency_band_id"]
      else
        band = data[band+"_band_id"].nil? ? ''  : data[band+"_band_id"]
      end
    end

    def transpose_number_tested(data)
      data["number_students_tested"].nil? ? '' : data["number_students_tested"]
    end

  end
end