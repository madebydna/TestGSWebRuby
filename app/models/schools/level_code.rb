class LevelCode
  attr_accessor :levels, :level_codes

  Level = Struct.new(:abbreviation, :long_name)

  LEVEL_LOOKUP = {'p' => Level.new('p', 'Preschool'),
                  'e' => Level.new('e', 'Elementary'),
                  'm' => Level.new('m', 'Middle'),
                  'h' => Level.new('h', 'High')
  }

  SORT_ORDER = %w(p e m h)

  def initialize(level_codes_string)
    @level_codes = level_codes_string.split(',').sort_by{|level| SORT_ORDER.index(level)}
    @levels = @level_codes.map{|code| LEVEL_LOOKUP[code]}
  end

  def eql? (level_code)
    (self.level_codes - level_code.level_codes).empty?
  end

  alias_method :==, :eql?

  def hash
    to_s.hash
  end

  def to_s
    @level_codes.join(',').to_s
  end

end
