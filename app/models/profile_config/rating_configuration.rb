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
    overall['use_school_value_float'].to_s == 'true'
  end

  def description_key
    configuration['description_key']
  end

  def data_type_id
    overall['data_type_id'] || star_rating['data_type_id']
  end

  def school_value(data_set)
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
    if subrating_hash.present? && rating_hash.present?
      rating_hash['rating_breakdowns'] = subrating_hash
    end
    if rating_hash['overall_rating'] && methodology_url
      rating_hash['methodology_url'] = methodology_url 
    end
    if rating_hash['overall_rating'] == 'nr'
      rating_hash['what_is_not_rated'] = what_is_not_rated
    end
    rating_hash
  end

  def overall_rating_hash(results, school)
    hash = {}
    if use_gs_rating?
      rating = school.school_metadata.overallRating
    else
      data_set = results.detect { |tds| tds['data_type_id'] == data_type_id }
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

  def subrating_hash(results, school)
    subrating_hash = {}

    breakdown_data_sets = results.select do |test_data_set|
      breakdown_data_type_ids.include?(test_data_set['data_type_id'])
    end

    rating_breakdowns.each do |key, breakdown_hash|
      matching_data_set = breakdown_data_sets.detect do |data_set|
        data_set['data_type_id'] == breakdown_hash['data_type_id']
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

    key = overall['methodology_url_key']
    if key.present?
      methodology_url = school.school_metadata[key.to_sym].presence
    end

    methodology_url ||= overall['default_methodology_url']
  end

  def private_school_disclaimer
    private_school_disclaimer_description = description_lookup_table[
      [state.upcase,'disclaimer_private']
    ]
  end
  
end