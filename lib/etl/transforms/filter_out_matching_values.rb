class  FilterOutMatchingValues
  def initialize(values_to_match, field)
    @values_to_match = values_to_match
    @field = field
    @values_transformed = []
  end

  def process(row)
    value = row[@field]
    if value_already_transformed?(value)
      return nil
    elsif value_match?(value)
      @values_transformed << value
      return nil
     else
      @values_transformed << value
      return row
    end
  end

  private
  def value_match?(value)
    @values_to_match.include?(value)
  end

  def  value_already_transformed?(value)
    @values_transformed.include?(value)
  end
end
