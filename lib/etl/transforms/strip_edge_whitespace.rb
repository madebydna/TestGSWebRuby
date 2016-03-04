class StripEdgeWhitespace
  def initialize(field, which_sides = :both)
    self.field = field
    self.which_sides = which_sides
  end

  def process(row)
    return row unless row[@field].present?

    case @which_sides
      when :both
        row[@field].strip!
      when :left
        row[@field].lstrip!
      when :right
        row[@field].rstrip!
    end

    row
  end

  def which_sides=(which_sides)
    unless [:left, :right, :both].include?(which_sides)
      raise 'which_sides must be either :both, :left, or :right'
    end
    @which_sides = which_sides
  end

  def field=(field)
    raise 'Field to strip whitespace from cannot be nil or empty' if field.empty?
    @field = field
  end
end

