module Latin1CharactersConcerns

  def only_latin1_characters?(*values)
    values.each do |value|
      # ISO-8859-1 is Latin-1
      latin_value = value.to_s.clone.force_encoding('ISO-8859-1')
      return false unless latin_value == value.to_s
    end
    true
  end

end
