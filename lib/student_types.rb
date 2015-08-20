module StudentTypes
  def self.all
    self.all_as_strings.map(&:to_sym)
  end

  def self.all_as_strings
    self.datatype_to_breakdown.values.map(&:downcase)
  end

  def self.all_datatypes
    self.datatype_to_breakdown.keys.map(&:to_sym)
  end

  def self.datatype_to_breakdown
    {
      'Students who are not economically disadvantaged'=> 'Not economically disadvantaged',
      'Students with disabilities' => 'Students with disabilities',
      'Not special education' => 'General-Education students',
      # AT-925, we're not sure what to map to Economically disadvantaged yet.
      'some datatype' => 'Economically disadvantaged',
      # 'Students participating in free or reduced-price lunch program'=> 'Economically disadvantaged',
      'English learners' => 'Limited English proficient',
      'Not English learners' => 'Not limited English proficient'
    }
  end
end
