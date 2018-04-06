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
    [
      {
        value: @row[:value_float],
        state: @source[:state],
        entity_level: @row[:entity_level],
        school_id: @row[:school_id],
        district_id: @row[:district_id],
        data_type_id: @row[:test_data_type_id],
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
        source_name: @source[:source_name],
        date_valid: @source[:date_valid],
        notes: @source[:notes],
        description: @source[:description]
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