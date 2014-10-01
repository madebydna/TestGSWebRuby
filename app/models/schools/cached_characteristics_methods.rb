module CachedCharacteristicsMethods

  NO_DATA_SYMBOL = '?'
  NO_ETHNICITY_SYMBOL = 'n/a'

  def characteristics
    cache_data['characteristics'] || {}
  end

  def students_enrolled
    characteristcs_value_by_name('Enrollment', grade: nil, number_value: true)
  end

  def characteristcs_value_by_name(name, options={})
    if valid_characteristic_cache(characteristics[name])
      characteristics[name].each do |characteristic|
        if options.present?
          if options.key? :grade
            next unless characteristic['grade'] == options[:grade]
          end
          if options[:number_value]
            return number_with_delimiter(characteristic['school_value'].to_i, delimiter: ',')
          else
            return characteristic['school_value']
          end
        else
          return characteristic['school_value']
        end
      end
      NO_DATA_SYMBOL
    else
      NO_DATA_SYMBOL
    end
  end

  def ethnicity_data
    characteristics['Ethnicity'] || []
  end


  def school_ethnicity(breakdown)
    ethnicity_obj = ethnicity_data.find { |ethnicity| ethnicity['breakdown'] == breakdown  }
    if ethnicity_obj && ethnicity_obj['school_value']
      ethnicity_obj['school_value'].round.to_s + '%'
    else
      NO_ETHNICITY_SYMBOL
    end
  end

  def graduates_high_school
    style_school_value_as_percent('Graduation rate')
  end

  def enroll_in_college
    style_school_value_as_percent('Percent enrolled in any institution of higher learning in the last 0-16 months')
  end

  def stays_2nd_year
    style_school_value_as_percent('Percent Enrolled in College and Returned for a Second Year')
  end

  def style_school_value_as_percent(data_name)
    if valid_characteristic_cache(characteristics[data_name])
      value = characteristics[data_name].first['school_value'].to_i
      if value
        "#{value.round(0)}%"
      end
    else
      NO_DATA_SYMBOL
    end
  end

  def free_and_reduced_lunch
    style_school_value_as_percent('Students participating in free or reduced-price lunch program')
  end

  def formatted_ethnicity_data
    characteristics['Ethnicity'].map { |eth|
                          {eth['breakdown']=> eth['school_value'].round.to_s + '%'}
    }.sort_by {|eth| -eth.values.first.to_i}
  end
  protected_method_defined?

  def valid_characteristic_cache(cache)
    if cache && cache.is_a?(Array)
      true
    else
      false
    end
  end




end