class Grade

  @@grade_hash = {}
  @@by_level_code_lookup = {}
  attr_accessor :value, :name, :alternative_names

  def initialize(value, name = nil, alternate_names = [])
    @value = value
    @name = name
    @alternate_names = alternate_names
    init_grade_hash
  end

  def init_grade_hash
    @@grade_hash[@value.to_s] = self

    if !@name.blank?
      @@grade_hash[@name] = self
    end

    if !@alternate_names.empty?
      @alternate_names.each do |alternate_name|
        @@grade_hash[alternate_name] = self
      end
    end
  end

  def to_s
    name || value
  end

  def self.from_string(value_or_name)
    @@grade_hash[value_or_name]
  end

  def self.from_level_code(level_code)
    @@by_level_code_lookup[level_code]
  end

  def self.initialize_all_grades
    Grade.new(-1, "PK", ["prek"])
    Grade.new(0, "KG", ["k", "K"])
    Grade.new(1)
    Grade.new(2)
    Grade.new(3)
    Grade.new(4)
    Grade.new(5)
    Grade.new(6)
    Grade.new(7)
    Grade.new(8)
    Grade.new(9)
    Grade.new(10)
    Grade.new(11)
    Grade.new(12)
    #(Refer to GS-13183)
    Grade.new(13)
    Grade.new(20, "UG", ["ungraded"])
    Grade.new(21, "AE")
    # values for "All", "Alle",etc grades are used to sort test scores.
    Grade.new(14, "All")
    Grade.new(15, "Alle")
    Grade.new(16, "Allem")
    Grade.new(16, "Allm")
    Grade.new(17, "Allmh")
    Grade.new(18, "Allh")
  end

  def self.initialize_level_code_lookup
    @@by_level_code_lookup = {
        LevelCode.new('e,m,h') => @@grade_hash['All'],
        LevelCode.new('e') => @@grade_hash['Alle'],
        LevelCode.new('e,m') => @@grade_hash['Allem'],
        LevelCode.new('m') => @@grade_hash['Allm'],
        LevelCode.new('m,h') => @@grade_hash['Allmh'],
        LevelCode.new('h') => @@grade_hash['Allh']
    }
  end

end

Grade.initialize_all_grades
Grade.initialize_level_code_lookup