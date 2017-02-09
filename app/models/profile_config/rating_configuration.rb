class RatingConfiguration
  attr_accessor :state, :configuration

  def initialize(state, hash)
    self.state = state
    self.configuration = hash
  end

  def hash
    configuration.clone
  end

  def description_lookup_table
    DataDescription.lookup_table
  end

  def description
    DataDescription.lookup_table[
      [state.upcase, overall['description_key']]
    ] ||
    DataDescription.lookup_table[
      [nil, overall['description_key']]
    ]
  end

  def what_is_not_rated
    DataDescription.lookup_table[
      [state.upcase, 'what_is_not_rated']
    ] ||
      DataDescription.lookup_table[
        [nil, 'what_is_not_rated']
      ]
  end

  def rating_breakdowns
    configuration['rating_breakdowns'] || {}
  end

  def breakdown_data_type_ids
    rating_breakdowns.values.map{ |r| r['data_type_id'] }
  end

  def overall
    configuration['overall'] || {}
  end

  def star_rating
    configuration['star_rating'] || {}
  end

  def label
    overall['label']
  end

  def use_gs_rating?
    overall['use_gs_rating'].to_s == 'true'
  end

  def use_school_value_float?
    star_rating['use_school_value_float'].to_s == 'true' ||
    Array.wrap(overall).first['use_school_value_float'].to_s == 'true'
  end

  def description_key
    configuration['description_key']
  end

  def level_code
    overall['level_code']
  end

  def data_type_id
    overall['data_type_id'] || star_rating['data_type_id']
  end

  def school_value(data_set)
    return data_set['school_value_float'] if data_set['data_type_id'] == 289

    if use_school_value_float?
      data_set['school_value_float'].round if data_set['school_value_float']
    else
      data_set['school_value_text']
    end
  end

  def rating_hash(results, school)
    rating_hash = overall_rating_hash(results, school)
    subrating_hash = subrating_hash(results, school)
    methodology_url = methodology_url(school)
    if rating_hash.present?
      Array.wrap(rating_hash).each do |rh|
        if subrating_hash.present?
          rh['rating_breakdowns'] = subrating_hash
        end
        if rh['overall_rating'] && methodology_url
          rh['methodology_url'] = methodology_url 
        end
        if rh['overall_rating'] == 'nr'
          rh['what_is_not_rated'] = what_is_not_rated
        end
      end
    end
    rating_hash
  end

  def overall_rating_hash(results, school)
    if overall.is_a?(Array)
      return overall.map do |overall_config|
        cloned_configuration = @configuration.dup
        cloned_configuration['overall'] = overall_config
        RatingConfiguration.new(state, cloned_configuration).overall_rating_hash(results, school)
      end
    else
      hash = {}
      if use_gs_rating?
        rating = school.school_metadata.overallRating
      else
        data_set = results.detect do |tds|
          tds['data_type_id'] == data_type_id &&
            (level_code.nil? || tds['level_code'] == level_code)
        end
        rating = school_value(data_set) if data_set
      end
      if use_gs_rating? && rating.blank? && !school.preschool?
        rating = 'nr'
      end
      if rating.present?
        hash = {
          'description' => description,
          'label' => label,
          'overall_rating' => rating
        }
      end
      hash
    end
  end

  def subrating_hash(results, school)
    subrating_hash = {}

    breakdown_data_sets = results.select do |test_data_set|
      breakdown_data_type_ids.include?(test_data_set['data_type_id'])
    end

    rating_breakdowns.each do |key, breakdown_hash|
      matching_data_set = breakdown_data_sets.detect do |data_set|
        data_set['data_type_id'] == breakdown_hash['data_type_id'] &&
          (breakdown_hash['level_code'].nil? || data_set['level_code'] == breakdown_hash['level_code'])
      end
      next if matching_data_set.nil?

      school_value = school_value(matching_data_set)

      if school_value.present?
        label_hash = {
          'rating' => school_value,
          'description' =>  RatingsHelper.get_sub_rating_descriptions(
                              breakdown_hash,
                              school,
                              description_lookup_table
                            )
        }
        label_hash.select! { |k,v| v.present? }

        subrating_hash[breakdown_hash['label']] = label_hash
      end
    end

    subrating_hash
  end

  def methodology_url(school)
    methodology_url = nil
    return methodology_url unless overall.present?

    key = Array.wrap(overall).first['methodology_url_key']
    if key.present?
      methodology_url = school.school_metadata[key.to_sym].presence
    end

    methodology_url ||= Array.wrap(overall).first['default_methodology_url']
  end

  def private_school_disclaimer
    private_school_disclaimer_description = description_lookup_table[
      [state.upcase,'disclaimer_private']
    ]
  end
  
end
