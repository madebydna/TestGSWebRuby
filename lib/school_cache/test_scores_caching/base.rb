class TestScoresCaching::Base < Cacher

  @@test_data_types = Hash[TestDataType.all.map { |f| [f.id, f] }]
  @@test_data_breakdowns = Hash[TestDataBreakdown.all.map { |f| [f.id, f] }]
  @@test_descriptions = Hash[TestDescription.all.map { |f| [f.data_type_id.to_s+f.state, f] }]
  @@proficiency_bands = Hash[TestProficiencyBand.all.map { |pb| [pb.id, pb] }]
  @@test_data_subjects = Hash[TestDataSubject.all.map { |o| [o.id, o] }]

  cattr_accessor :test_data_types, :test_data_breakdowns, :test_descriptions, :proficiency_bands, :test_data_subjects

  def test_data_types
    @@test_data_types
  end

  def test_descriptions
    @@test_descriptions
  end

  def proficiency_bands
    @@proficiency_bands
  end

  def test_data_breakdowns
    @@test_data_breakdowns
  end

  def test_data_subjects
    @@test_data_subjects
  end

  def self.listens_to?(data_type)
    :test_scores == data_type
  end
end