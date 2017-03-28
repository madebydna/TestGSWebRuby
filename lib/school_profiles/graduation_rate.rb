class SchoolProfiles::GraduationRate
  attr_reader :school_cache_data_reader, :data_types


  def initialize(school_cache_data_reader:)
    @school_cache_data_reader = school_cache_data_reader
    @data_types = [
      '4-year high school graduation rate',
      'Percent of students who meet UC/CSU entrance requirements'
    ]
  end

  def to_hash
    apply_narratives
    h = school_cache_data_reader.characteristics.slice(*data_types)
    h
  end

  def apply_narratives
    # currently this works by mutating the school cache data reader's internal
    # memoized data structure, which has the side effect of making the data
    # reader return characteristics data with the narrative texts
    SchoolProfiles::NarrativeLowIncomeGradRateAndEntranceReq.new(
      school_cache_data_reader: school_cache_data_reader
    ).auto_narrative_calculate_and_add
  end
end
