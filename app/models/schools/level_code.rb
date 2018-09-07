class LevelCode
  attr_accessor :levels, :level_codes

  Level = Struct.new(:abbreviation, :long_name)

  GRADES_WHITELIST = ['pk', 'kg'].concat((1..12).to_a.map(&:to_s))

  LEVEL_LOOKUP = {
    'p' => Level.new('p', 'Preschool'),
    'e' => Level.new('e', 'Elementary'),
    'm' => Level.new('m', 'Middle'),
    'h' => Level.new('h', 'High')
  }.freeze

  SORT_ORDER = %w(p e m h).freeze

  def initialize(level_codes_string)
    @level_codes = level_codes_string.split(',').sort_by { |level| SORT_ORDER.index(level) }
    @levels = @level_codes.map { |code| LEVEL_LOOKUP[code] }
  end

  def eql?(other)
    (level_codes - other.level_codes).empty?
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
      when 'pk', 'p'
        'p'
      when 'kg', 'k', '1', '2', '3', '4', '5'
        'e'
      when '6', '7', '8'
        'm'
      when '9', '10', '11', '12', '13'
        'h'
      else
        nil
      end
    LevelCode.new(level_code) if level_code
  end

  def self.full_from_grade(grade)
    grade_levels = from_grade(grade.to_s) if grade.try(:to_s).is_a? String
    grade_levels.levels.first.long_name if grade_levels
  end

  def self.from_all_grades(grades_string)
    grades = grades_string.split(',')
    grades.map {|grade| from_grade(grade).to_s}.uniq.sort.join(',')
  end

  def self.full_from_all_grades(level_code_string)
    level_code_string.split(',').reduce([]) {|accum, string| accum << LevelCode::LEVEL_LOOKUP[string].long_name }.join(', ')
  end
end
