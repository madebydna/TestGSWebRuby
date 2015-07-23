module StudentTypes
  def self.all
    [
      'Not economically disadvantaged'.to_sym,
      'Students with disabilities'.to_sym,
      'General-Education students'.to_sym,
      'Economically disadvantaged'.to_sym,
      'Limited English proficient'.to_sym,
      'Not limited English proficient'.to_sym,
    ]
  end
end
