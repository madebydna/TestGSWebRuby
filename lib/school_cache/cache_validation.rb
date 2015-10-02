module CacheValidation

  include SchoolDataValidation

  def validate!(cache)
    @cache = cache

    # List the methods you want to run here.
    # Note that order is important!
    validate_format!
    validate_ethnicities!

    @cache
  end

  # Place validation methods below this comment.
  # Validations will be executed in the order that they are listed here.
  # Please give methods understandable names and logic with
  # comments when necessary. The goal is for a wide audience to
  # understand this business logic.

  def validate_format!
    remove_empty_values!
  end

  def remove_empty_values!
    @cache.keep_if do | char_type, values |
      values.present? or (log_data_rejection(@state,@school.id,char_type,"No value found") and false)
    end
  end

  def validate_ethnicities!
    if @cache['Ethnicity']
      use_best_ethnicity_source!
      assert_reasonable_ethnicity_sum!
    end
  end

  def assert_reasonable_ethnicity_sum!
    total_value = 0
    min_allowed = 85
    max_allowed = 105
    @cache['Ethnicity'].each do |ethnicity|
      total_value += ethnicity[:school_value].to_i
    end
    if total_value < min_allowed || total_value > max_allowed
      @cache.except!('Ethnicity')
      log_data_rejection(@state,@school.id,'Ethnicity',"Percent only added to #{total_value}")
    end
  end

  def use_best_ethnicity_source!
    sources = Hash.new { |h,k| h[k] = 0 }
    @cache['Ethnicity'].each do |ethnicity|
      sources[ethnicity[:source]] += ethnicity[:school_value].to_i
    end
    best_source = sources.max_by{|k,v| v}.first
    @cache['Ethnicity'].each do |ethnicity|
      @cache['Ethnicity'].delete(ethnicity) unless ethnicity[:source] == best_source
    end
  end

end
