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

  def self.from_grade(grade)
    level_code =
      case grade.downcase
        when 'pk'
          'p'
        when 'kg','1','2','3','4','5'
          'e'
        when '6','7','8'
          'm'
        when '9','10','11','12','13'
          'h'
        else
          nil
      end
    LevelCode.new(level_code) if level_code
  end

end
