# frozen_string_literal: true

module MetaTag

  # SimpleDelegator allows us to pass messages to the object the class is initialized with. Here, we want to be able to
  # ask the controller for information (like params) to construct tags.
  class MetaTags < SimpleDelegator
    include UrlHelper

    def initialize(controller)
      super(controller)
    end

    def meta_tag_hash
      {
        robots: robots,
        title: "#{title} | GreatSchools",
        description: description,
        canonical: canonical_url,
        prev: prev_url,
        next: next_url,
        alternate: alternate_url,
        og: og,
        twitter: twitter
      }.gs_remove_empty_values
    end

    private

    def og
      nil
    end

    def twitter
      nil
    end

    def alternate_url
      {
        en: url_for(params_for_canonical.merge(lang: nil)),
        es: url_for(params_for_canonical.merge(lang: :es))
      }
    end

    def robots
      'noindex' unless is_browse_url? && any_results?
    end

    def prev_url
      param_to_remove = view == default_view ? view_param_name : nil
      prev_page_url(page_of_results, param_to_remove)
    end

    def next_url
      param_to_remove = view == default_view ? view_param_name : nil
      next_page_url(page_of_results, param_to_remove)
    end

    def canonical_url
      raise NotImplementedError.new("#{self.class.name}#canonical_url must be implemented even if it should return nil")
    end

    def description
      raise NotImplementedError.new("#{self.class.name}#description must be implemented even if it should return nil")
    end

    def params_for_canonical
      {}.tap do |key|
        key[grade_level_param_name] = level_codes if level_code.present?
        key[page_param_name] = given_page if given_page.present?
        key[school_type_param_name] = entity_types if entity_types.present?
        key[view_param_name] = view if view.present? && view != default_view
        key[table_view_param_name] = tableView if tableView.present?
      end.compact
    end

    def title_pagination_text
      ", #{page_of_results.index_of_first_result}-#{page_of_results.index_of_last_result}"
    end

    def entity_type_long
      {
        'charter' => 'Public Charter ',
        'public' => 'Public ',
        'private' => 'Private '
      }[entity_type]
    end

    def level_code_long
      {
        'e' => 'Elementary ',
        'm' => 'Middle ',
        'h' => 'High ',
        'p' => nil
      }[level_code]
    end

    def schools_or_preschools
      school_preschool_map = Hash.new('Schools').merge('p' => 'Preschools')
      school_preschool_map[level_code]
    end
  end
end