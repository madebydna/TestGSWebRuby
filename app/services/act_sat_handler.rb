# This class handles the filtering of SAT/ACT data to only the most recent data
class ActSatHandler
  include SchoolProfiles::CollegeReadinessConfig

  attr_reader :hash

  def initialize(hash)
    @hash = hash
  end

  def handle_ACT_SAT_to_display!
    # returns max_year if we have at least one ACT data type to display, else: nil
    act_content = enforce_latest_year_school_value_for_data_types!(ACT_SCORE, ACT_PARTICIPATION, ACT_PERCENT_COLLEGE_READY)
    # returns max_year if we have at least one SAT data type to display, else: nil
    sat_content = enforce_latest_year_school_value_for_data_types!(SAT_SCORE, SAT_PARTICIPATION, SAT_PERCENT_COLLEGE_READY)

    remove_crdc_for_unfresh_data(act_content, sat_content)

    if act_content || sat_content
      remove_crdc_breakdown!(ACT_SAT_PARTICIPATION, ACT_SAT_PARTICIPATION_9_12)
    else
      # if no ACT/SAT content, we check ACT/SAT participation data and set school_values of records older than max_year data to nil
      enforce_latest_year_gsdata!(ACT_SAT_PARTICIPATION, ACT_SAT_PARTICIPATION_9_12)
      # Select 9-12 data for all students
      part912 = hash.slice(ACT_SAT_PARTICIPATION_9_12).values.flatten.select(&:all_students?).flatten
      # Prioritize 9-12 data over non-9-12 data
      remove_crdc_breakdown!(ACT_SAT_PARTICIPATION) if part912.present?
    end
  end

  # JT-8787: Displayed ACT & SAT data must be within 2 years of one another, otherwise hide the older data type
  def remove_crdc_for_unfresh_data(act_content, sat_content)
    return unless act_content && sat_content
    return unless ((act_content - sat_content).abs > 2)
    if act_content > sat_content
      return remove_crdc_breakdown!(SAT_SCORE, SAT_PARTICIPATION, SAT_PERCENT_COLLEGE_READY)
    end
    remove_crdc_breakdown!(ACT_SCORE, ACT_PARTICIPATION, ACT_PERCENT_COLLEGE_READY)
  end

  def enforce_latest_year_gsdata!(*data_types)
    data_type_hashes = hash.slice(*data_types).values.flatten.select(&:all_students?).flatten.extend(SchoolProfiles::CollegeReadinessComponent::CharacteristicsValue::CollectionMethods)
    max_year = data_type_hashes.having_most_recent_date.first.year
    data_type_hashes.each do |v|
      if v.year < max_year
        v.school_value = nil
      end
    end
  end

  def remove_crdc_breakdown!(*data_types)
    data_type_hashes = hash.slice(*data_types).values.flatten.select do |tds|
      tds.all_students?
    end.flatten
    data_type_hashes.each do |h|
      h.school_value = nil
    end
  end

  # TODO Create method to handle ACT_SAT_PARTICIPATION
  # Assuming we have >= 1 year(s)' worth of school_values for a given data type,
  # this will return the most recent year (i.e., "max year") for which we have data
  # and set all previous years' school_values to nil
  def enforce_latest_year_school_value_for_data_types!(*data_types)
    data_type_hashes = build_data_type_hashes(data_types)
    max_year = get_max_year(data_type_hashes)
    check_school_value_max(data_type_hashes, max_year)
  end

  def build_data_type_hashes(data_types)
    hash.slice(*data_types).values.flatten.select do |tds|
      tds.all_subjects_and_students?
    end.flatten
  end

  def get_max_year(data_type_hashes)
    data_type_hashes.map { |dts| dts.year }.max
  end

  def check_school_value_max(data_type_hashes, max_year)
    return_value     = nil
    data_type_hashes.each do |h|
      if school_value_present?(h["school_value_#{max_year}"])
        return_value = max_year
      else
        h.school_value = nil
      end
    end
    return_value
  end

  def school_value_present?(value)
    value.present? && value.to_s != '0.0' && value.to_s != '0'
  end
end