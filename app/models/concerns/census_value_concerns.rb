module CensusValueConcerns
  extend ActiveSupport::Concern

  # column name is modifiedBy, which breaks convention.
  # I tried using alias_method but that didn't work
  def modified_by
    modifiedBy
  end

  def modified_by=(arg)
    self.modifiedBy = arg
  end

  def value
    value_float || value_text
  end

  def value_int
    value_float? ? value_float.round : 0
  end

end
