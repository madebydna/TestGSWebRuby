class NilClass
  def to_bool
    nil
  end

  def numeric?
    false
  end
end