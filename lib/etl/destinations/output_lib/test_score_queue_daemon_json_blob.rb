# frozen_string_literal: true

require 'json'

class TestScoreQueueDaemonJsonBlob

  def initialize(row, source)
    @row = row
    @source = source
  end

  def build
    { test_scores: test_scores_hash }.to_json
  end

  def test_scores_hash
    @source[:source_name] = %Q{#{@source[:source_name]}}
    district_id = @row[:district_id]
    school_id = @row[:school_id]
    if district_id == "state" || district_id.nil?
      district_id = nil
    else district_id = district_id.to_s
    end
    if school_id == "state" || school_id == "district" || school_id.nil?
      school_id = nil
    else school_id = school_id.to_s
    end
    [
      {
        value: @row[:value_float],
        state: @source[:state],
        entity_level: @row[:entity_level],
        school_id: school_id,
        district_id: district_id,
        data_type_id: @row[:gsdata_test_data_type_id],
        proficiency_band_id: @row[:proficiency_band_gsdata_id],
        cohort_count: @row[:number_tested],
        grade: @row[:grade],
        active: 1,
        breakdowns: breakdowns_hash,
        academics: academics_hash,
        source: source_hash,
        year: @row[:year],
        configuration: @source[:configuration],
      }
    ]
  end

  def source_hash
    {
        source_name: @row[:source_name] || @source[:source_name],
        date_valid: @row[:date_valid] || @source[:date_valid],
        notes: @row[:notes] || @source[:notes],
        description: @row[:description] || @source[:description]
    }
  end

  def academics_hash
    [
        {
            id: @row[:academic_gsdata_id],
        }
    ]
  end

  def breakdowns_hash
    [
        {
            id: @row[:breakdown_gsdata_id],
        }
    ]
  end

end