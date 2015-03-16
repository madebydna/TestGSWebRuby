class CensusDataCountryValue < ActiveRecord::Base
  db_magic :connection => :gs_schooldb
  self.table_name='census_data_country_value'

  belongs_to :census_data_set, :class_name => 'CensusDataSet', foreign_key: 'data_set_id'
  belongs_to :country, :class_name => 'Country'

  default_scope -> { where(active: true) }

  def self.get_country_scores_by_subject
    final_hash = []
    country_scores =  CensusDataCountryValue.preload(:country)
    data_set_ids = country_scores.map(&:data_set_id)
    subjects = CensusDataSet.on_db(:gs_schooldb).where(id:data_set_ids,active: 1).preload(:test_data_subject)

    subjects.each_with_index  do | subject, index |
      final_hash << {
          :subject_id => subject.test_data_subject.id,
          :subject_name => subject.test_data_subject.name,
          :scores => get_scores_as_array(country_scores, index)}
    end
    final_hash
  end

  def self.get_scores_as_array(country_scores, index)
    score_array = []
    scores = country_scores.where(data_set_id:index+1).order("value_float DESC")
    scores.each  do | score |
      score_array << {country_name: score.country.name, country_score: score.value_float}
    end
    score_array
  end
end