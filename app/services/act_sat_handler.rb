# This class handles the filtering of SAT/ACT data to only the most recent data
class ActSatHandler
  include SchoolProfiles::CollegeReadinessConfig

  attr_reader :hash

  ACT_ONLY = [ACT_SCORE, ACT_PARTICIPATION, ACT_PERCENT_COLLEGE_READY]
  SAT_ONLY = [SAT_SCORE, SAT_PARTICIPATION, SAT_PERCENT_COLLEGE_READY]
  ACT_SAT_COMBINED_PARTICIPATION = [ACT_SAT_PARTICIPATION, ACT_SAT_PARTICIPATION_9_12]

  def initialize(hash, value_type = "school_value")
    @hash = hash
    @value_type = value_type
  end

  def handle_ACT_SAT_to_display!
    act_data = select_by_data_types(*ACT_ONLY, &:all_subjects_and_students?)
    act_max_year = act_data.any? ? get_max_year(act_data) : nil
    enforce_latest_year_gsdata!(act_data, act_max_year) if act_max_year

    sat_data = select_by_data_types(*SAT_ONLY, &:all_subjects_and_students?)
    sat_max_year = sat_data.any? ? get_max_year(sat_data) : nil
    enforce_latest_year_gsdata!(sat_data, sat_max_year) if sat_max_year

    remove_older_sat_or_act_data(act_max_year, sat_max_year)

    if act_max_year || sat_max_year
      remove_by_data_types!(*ACT_SAT_COMBINED_PARTICIPATION)
    else
      # if no ACT/SAT content, we check ACT/SAT participation data and set school_values of records older than max_year data to nil
      combined_participation_data = select_by_data_types(*ACT_SAT_COMBINED_PARTICIPATION, &:all_subjects_and_students?)
      enforce_latest_year_gsdata!(combined_participation_data)
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

  def enforce_latest_year_gsdata!(records, max_year=nil)
    #records = select_by_data_types(*data_types, &:all_students?)
    max_year ||= get_max_year(records)
    older_records = records.select {|v| v.year < max_year}
    set_value_to_nil(older_records)
  end

  # remove school value for all students for selected data types
  def remove_by_data_types!(*data_types)
    records = select_by_data_types(*data_types, &:all_students?)
    set_value_to_nil(records)
  end

  def get_max_year(records)
    records.map { |dts| dts.year }.max
  end

  private

  def select_by_data_types(*data_types, &block)
    hash.slice(*data_types).values.flatten.select {|item| block.call(item) }.flatten
  end

  def set_value_to_nil(array)
    array.each do |h|
      h.send("#{@value_type}=".to_sym, nil)
    end
  end
end