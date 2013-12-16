class String

  # Uppercase only first letter string. Modifies string and returns it
  def gs_capitalize_first!
    self[0] = self[0].upcase
    self
  end

  # Return new string with first letter capitalized
  def gs_capitalize_first
    self[0].upcase + self[1..-1]
  end

end