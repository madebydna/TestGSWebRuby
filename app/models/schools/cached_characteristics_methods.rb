module CachedCharacteristicsMethods

  NO_DATA_SYMBOL = '?'
  NO_ETHNICITY_SYMBOL = 'n/a'
  REMEDIATION_SUBJECTS_FOR_CSA = ['All subjects', 'English', 'Math']

  def characteristics
    cache_data['characteristics'] || {}
  end

  def students_enrolled(opts = {})
    opts.reverse_merge!(grade: nil, number_value: true)
    characteristcs_value_by_name('Enrollment', opts)
  end

  def numeric_enrollment
    characteristcs_value_by_name('Enrollment')
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
    end
    NO_DATA_SYMBOL unless options[:allow_nil]
  end

  def census_value(name, options={})
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
    end
  end

  def created_time(name)
    if valid_characteristic_cache(characteristics[name]) && characteristics[name].present? && characteristics[name].first['created'].present?
      Time.parse(characteristics[name].first['created'])
    end
  end

  def school_leader
    census_value('Head official name')
  end

  def school_leader_email
    census_value('Head official email address')
  end

  def ethnicity_data
    characteristics['Ethnicity'] || []
  end

  def OECD_data
    characteristics['OECD PISA Test for Schools'] || []
  end

  def school_ethnicity(breakdown)
    ethnicity_obj = ethnicity_data.find { |ethnicity| ethnicity['breakdown'] == breakdown  }
    if ethnicity_obj && ethnicity_obj['school_value']
      ethnicity_obj['school_value'].round.to_s + '%'
    else
      NO_ETHNICITY_SYMBOL
    end
  end

  def college_readiness(display_and_key_type)
    @_college_readiness ||= (
      display_and_key_type.map do | hash |
        {:display_type => hash[:display_type], :data => characteristics[hash[:data_key]]}
      end
    )
  end

  def graduates_high_school
    style_school_value_as_percent('Graduation rate')
  end

  def enroll_in_college
    value = style_school_value_as_percent('Percent enrolled in any institution of higher learning in the last 0-16 months')
    value == NO_DATA_SYMBOL ? 'N/A' : value
  end

  def stays_2nd_year
    value = style_school_value_as_percent('Percent Enrolled in College and Returned for a Second Year') 
    value == NO_DATA_SYMBOL ? 'N/A' : value
  end

  def graduates_remediation
    # create three variables and supress if something isn't present
    @_graduates_remediation ||= characteristics['Percent Needing Remediation for College'] || []
  end

  def graduates_remediation_for_college_success_awards
    return [] unless graduates_remediation.present?
    data = graduates_remediation.select { |data| data["breakdown"] == 'All students' && (data["subject"] == nil || REMEDIATION_SUBJECTS_FOR_CSA.include?(data["subject"])) }
    data.map do |datum|
      {}.tap do |hash|
        next unless datum["school_value"]
        if datum["subject"]
          hash["subject"] = datum["subject"]
          hash["school_value"] = "#{datum["school_value"].round(0)}%"
        else
          hash["subject"] = "All subjects"
          hash["school_value"] = "#{datum["school_value"].round(0)}%"
        end
      end
    end     
  end

  def style_school_value_as_percent(data_name)
    if valid_characteristic_cache(characteristics[data_name])
      value = characteristics[data_name].first['school_value'].to_i
      if value
        return "#{value.round(0)}%"
      end
    end
    NO_DATA_SYMBOL
  end

  def free_and_reduced_lunch
    style_school_value_as_percent('Students participating in free or reduced-price lunch program')
  end

  def free_or_reduced_price_lunch_data
    characteristics['Students participating in free or reduced-price lunch program'] || []
  end

  def formatted_ethnicity_data
    formatted_eth_data = {}
    ethnicity_data.each do |eth|
      formatted_eth_data[eth['breakdown']] =  if eth['school_value']
                                                eth['school_value'].round.to_s + '%'
                                              else
                                                NO_ETHNICITY_SYMBOL
                                              end
    end
    formatted_eth_data
  end
  protected

  def valid_characteristic_cache(cache)
    if cache && cache.is_a?(Array)
      true
    else
      false
    end
  end



end
