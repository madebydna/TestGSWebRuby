# This class handles the filtering of SAT/ACT data to only the most recent data
class ActSatHandler
  include MetricsCaching::CollegeReadinessConfig

  attr_reader :hash

  ACT_ONLY = [ACT_SCORE, ACT_PARTICIPATION, ACT_PERCENT_COLLEGE_READY]
  SAT_ONLY = [SAT_SCORE, SAT_PARTICIPATION, SAT_PERCENT_COLLEGE_READY]
  ACT_SAT_COMBINED_PARTICIPATION = [ACT_SAT_PARTICIPATION, ACT_SAT_PARTICIPATION_9_12]

  def initialize(hash)
    @hash = hash
  end

  def handle_ACT_SAT_to_display!
    act_max_year = get_max_year_by_data_types(*ACT_ONLY)
    remove_earlier_than_max_year_by_data_types!(*ACT_ONLY, act_max_year)

    sat_max_year = get_max_year_by_data_types(*SAT_ONLY)
    remove_earlier_than_max_year_by_data_types!(*SAT_ONLY, sat_max_year)

    remove_older_sat_or_act_data(act_max_year, sat_max_year)

    if act_max_year || sat_max_year
      remove_by_data_types!(*ACT_SAT_COMBINED_PARTICIPATION)
    else
      # if no ACT/SAT content, we check ACT/SAT participation data and set school_values of records older than max_year data to nil
      combined_max_year = get_max_year_by_data_types(*ACT_SAT_COMBINED_PARTICIPATION)
      remove_earlier_than_max_year_by_data_types!(*ACT_SAT_COMBINED_PARTICIPATION, combined_max_year)
    end
  end

  # JT-8787: If ACT & SAT data are not within 2 years of one another, remove the older data
  def remove_older_sat_or_act_data(act_max_year, sat_max_year)
    return unless act_max_year && sat_max_year
    return unless ((act_max_year - sat_max_year).abs > 2)
    if act_max_year > sat_max_year
      return remove_by_data_types!(*SAT_ONLY)
    end
    remove_by_data_types!(*ACT_ONLY)
  end

  def remove_by_data_types!(*data_types)
    hash.except!(*data_types)
  end

  def get_max_year(records)
    records.map { |dts| dts.year }.max
  end

  def get_max_year_by_data_types(*data_types)
    selected = select_by_data_types(*data_types, &:all_subjects_and_students?)
    selected.any? ? get_max_year(selected) : nil
  end

  def remove_earlier_than_max_year_by_data_types!(*data_types, max_year)
    hash.slice(*data_types).each do |k, values|
      values.reject! {|val| val.all_subjects_and_students? && val.year < max_year}
    end
  end

  private

  def select_by_data_types(*data_types, &block)
    hash.slice(*data_types).values.flatten.select {|item| block.call(item) }.flatten
  end
end