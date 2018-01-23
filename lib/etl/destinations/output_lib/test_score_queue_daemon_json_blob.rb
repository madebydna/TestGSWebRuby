# frozen_string_literal: true

require 'json'

class TestScoreQueueDaemonJsonBlob

  def self.build(row, source)
    hash = { :test_scores => test_scores_hash(row, source)}
    hash.to_json if hash.present?
  end

  def self.test_scores_hash(row, source)
    [
      {
        :value => row[:value_float],
        :state => source[:state],
        :entity_level => row[:entity_level],
        :school_id => row[:school_id],
        :district_id => row[:district_id],
        :data_type_id => row[:test_data_type_id],
        :subject_id => row[:subject_id],
        :proficiency_band_id => row[:proficiency_band_id],
        :cohort_count => row[:number_tested],
        :grade => row[:grade],
        :active => 1,
        :breakdowns => breakdowns_hash(row),
        :source => source_hash(source),
        :year => row[:year]
      }
    ]
  end

  def self.source_hash(source)
    {
      :source_name => source[:source_name],
      :date_valid => source[:date_valid],
      :notes => source[:notes]
    }
  end

  def self.breakdowns_hash(row)
    [
      {
        :id => row[:breakdown_id],
        :name => row[:breakdown],
      }
    ]
  end

end