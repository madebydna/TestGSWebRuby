module CharacteristicsCaching::Validation

  include SchoolDataValidation

  def validate!(characteristics)
    @characteristics = characteristics

    # List the methods you want to run here.
    # Note that order is important!
    validate_ethnicities!

    @characteristics
  end

  # Place validation methods below this comment.
  # Validations will be executed in the order that they are listed here.
  # Please give methods understandable names and logic with
  # comments when necessary. The goal is for a wide audience to
  # understand this business logic.

  def validate_ethnicities!
    if @characteristics['Ethnicity']
      use_best_ethnicity_source!
      assert_reasonable_ethnicity_sum!
    end
  end

  def assert_reasonable_ethnicity_sum!
    total_value = 0
    min_allowed = 85
    max_allowed = 105
    @characteristics['Ethnicity'].each do |ethnicity|
      total_value += ethnicity[:school_value].to_i
    end
    if total_value < min_allowed || total_value > max_allowed
      @characteristics.except!('Ethnicity')
      log_data_rejection(@state,@school.id,'Ethnicity',"Percent only added to #{total_value}")
    end
  end

  def use_best_ethnicity_source!
    sources = Hash.new { |h,k| h[k] = 0 }
    @characteristics['Ethnicity'].each do |ethnicity|
      sources[ethnicity[:source]] += ethnicity[:school_value].to_i
    end
    best_source = sources.max_by{|k,v| v}.first
    @characteristics['Ethnicity'].each do |ethnicity|
      @characteristics['Ethnicity'].delete(ethnicity) unless ethnicity[:source] == best_source
    end
  end

end