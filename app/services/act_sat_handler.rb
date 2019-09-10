# This class handles the filtering of SAT/ACT data to only the most recent data
class ActSatHandler
  include SchoolProfiles::CollegeReadinessConfig

  attr_reader :hash
  
  ACT_ONLY = [ACT_SCORE, ACT_PARTICIPATION, ACT_PERCENT_COLLEGE_READY]
  SAT_ONLY = [SAT_SCORE, SAT_PARTICIPATION, SAT_PERCENT_COLLEGE_READY]
  ACT_SAT_COMBINED_PARTICIPATION = [ACT_SAT_PARTICIPATION, ACT_SAT_PARTICIPATION_9_12]

  def initialize(hash)
    @hash = hash
  end

  def handle_ACT_SAT_to_display!
    # returns max_year if we have at least one ACT data type to display, else: nil
    act_max_year = enforce_latest_year_school_value_for_data_types!(*ACT_ONLY)
    # returns max_year if we have at least one SAT data type to display, else: nil
    sat_max_year = enforce_latest_year_school_value_for_data_types!(*SAT_ONLY)

    remove_crdc_for_unfresh_data(act_max_year, sat_max_year)

    if act_max_year || sat_max_year
      remove_crdc_breakdown!(*ACT_SAT_COMBINED_PARTICIPATION)
    else
      # if no ACT/SAT content, we check ACT/SAT participation data and set school_values of records older than max_year data to nil
      enforce_latest_year_gsdata!(*ACT_SAT_COMBINED_PARTICIPATION)
      # Select 9-12 data for all students
      part912 = select_by_data_types(ACT_SAT_PARTICIPATION_9_12, &:all_students?)
      # Prioritize 9-12 data over non-9-12 data
      remove_crdc_breakdown!(ACT_SAT_PARTICIPATION) if part912.present?
    end
  end

  # JT-8787: Displayed ACT & SAT data must be within 2 years of one another, otherwise hide the older data type
  def remove_crdc_for_unfresh_data(act_max_year, sat_max_year)
    return unless act_max_year && sat_max_year
    return unless ((act_max_year - sat_max_year).abs > 2)
    if act_max_year > sat_max_year
      return remove_crdc_breakdown!(*SAT_ONLY)
    end
    remove_crdc_breakdown!(*ACT_ONLY)
  end

  def enforce_latest_year_gsdata!(*data_types)
    records = select_by_data_types(*data_types, &:all_students?)
    max_year = get_max_year(records)
    older_records = records.select {|v| v.year < max_year}
    set_school_value_to_nil(older_records)
  end

  # remove school value for all students for selected data types
  def remove_crdc_breakdown!(*data_types)
    records = select_by_data_types(*data_types, &:all_students?)
    set_school_value_to_nil(records)
  end

  # TODO Create method to handle ACT_SAT_PARTICIPATION
  # Assuming we have >= 1 year(s)' worth of school_values for a given data type,
  # this will return the most recent year (i.e., "max year") for which we have data
  # and set all previous years' school_values to nil
  def enforce_latest_year_school_value_for_data_types!(*data_types)
    records = select_by_data_types(*data_types, &:all_subjects_and_students?)
    max_year = get_max_year(records)
    check_school_value_max(records, max_year)
  end

  def get_max_year(records)
    records.map { |dts| dts.year }.max
  end

  def check_school_value_max(records, max_year)
    max_year_records, older_records = records.partition { |h| school_value_present?(h["school_value_#{max_year}"]) }
    set_school_value_to_nil(older_records)

    max_year_records.any? ? max_year : nil
  end

  def school_value_present?(value)
    value.present? && !value.zero?
  end

  private

  def select_by_data_types(*data_types, &block)
    hash.slice(*data_types).values.flatten.select{|item| block.call(item) }.flatten
  end

  def set_school_value_to_nil(array)
    array.each do |h|
      h.school_value = nil
    end
  end
end