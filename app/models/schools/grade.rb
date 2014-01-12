class Grade

  @@grade_hash = {}
  #private_class_method :new

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

  def self.grade_hash
    @@grade_hash
  end

  def self.get_grade(value_or_name)
    @@grade_hash[value_or_name]
  end

  def get_value
    @value
  end

  def get_name
    @name
  end

  def get_alternative_names
    @alternate_names
  end

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
  Grade.new(13)
  Grade.new(20, "UG", ["ungraded"])
  Grade.new(21, "AE")
  Grade.new(14, "All")
  Grade.new(15, "Alle")
  Grade.new(16, "Allem")
  Grade.new(16, "Allm")
  Grade.new(17, "Allmh")
  Grade.new(18, "Allh")

end