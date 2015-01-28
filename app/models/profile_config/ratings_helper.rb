class RatingsHelper

  attr_accessor :ratings_config, :results

  def initialize(results,ratings_config)
    @ratings_config = ratings_config
    @results = results
  end

  [:gs, :state, :city, :pcsb, :preschool].each do |rating_type|
    method_name = "construct_#{rating_type}_rating".to_sym
    define_method method_name do |school|
      config = ratings_config.send "#{rating_type}_rating"
      return {} unless config.present?
      rating_configuration = RatingConfiguration.new(school.state, config)
      rating_hash = rating_configuration.rating_hash(results, school)
      if rating_type == :gs &&
        rating_configuration.private_school_disclaimer.present? &&
        rating_hash['overall_rating'].present? && school.private_school? &&
          rating_hash['disclaimer_private'] = rating_configuration.private_school_disclaimer
      end
      rating_hash
    end
  end

  def self.get_sub_rating_descriptions(gs_rating_configuration, school, description_hash)
    description = ''
    if gs_rating_configuration && gs_rating_configuration['description_key'].present?
      description << (description_hash[[nil, gs_rating_configuration['description_key']]] || '')
    end
    if gs_rating_configuration && gs_rating_configuration['footnote_key'].present?
      description << ' ' if description.present?
      footnote_description = description_hash[[school.state.upcase, gs_rating_configuration['footnote_key']]]
      description << footnote_description if footnote_description
    end
    description
  end

end
