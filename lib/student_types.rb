module StudentTypes
  def self.all
    self.all_as_strings.map(&:to_sym)
  end

  def self.all_as_strings
    self.datatype_breakdown_map.values.map(&:downcase)
  end

  def self.all_datatypes
    self.datatype_breakdown_map.keys.map(&:to_sym)
  end

  def self.datatype_to_breakdown(datatype)
    if (student_type = self.datatype_breakdown_map[datatype])
      student_type
    else
      datatype
    end
  end

  def self.general_education_breakdown_label
    'General-Education students'
  end

  # Student types aren't necessarily the same name as their breakdowns so we map
  # the datatype (used above to get the data) to its breakdown here.
  def self.datatype_breakdown_map
    {
      'Students who are not economically disadvantaged'=> 'Not economically disadvantaged',
      'Students with disabilities' => 'Students with disabilities',
      'Not special education' => general_education_breakdown_label,
      'Students participating in free or reduced-price lunch program'=> 'Economically disadvantaged',
      'English learners' => 'Limited English proficient',
      'Not English learners' => 'Not limited English proficient'
    }
  end
end
