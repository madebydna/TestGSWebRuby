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

  # Similar to string.titlecase, but does not mess with other characters in the string,
  # such as replacing :: with \ or downcasing acronyms
  def gs_capitalize_words
    # Taken from ActiveSupport string inflections.rb
    self.gsub(/\b('?[a-z])/) { $1.capitalize }
  end

  def gs_capitalize_words!
    replace gs_capitalize_words
  end

end