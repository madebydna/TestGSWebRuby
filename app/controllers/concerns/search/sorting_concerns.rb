module SortingConcerns
  extend ActiveSupport::Concern

  protected

  SORT_TYPES = ['rating_asc', 'rating_desc', 'fit_asc', 'fit_desc', 'distance_asc', 'distance_desc', 'name_asc', 'name_desc']

  def determine_sort!(params_hash=params)
    params_sort = parse_sorts(params_hash).presence
    @active_sort = active_sort_name(params_sort)
    @relevant_sort_types = sort_types
    params_sort
  end

  def active_sort_name(sort)
    if sort.nil?
      if search_by_location?
        :distance
      elsif search_by_name?
        :relevance
      else
        :rating
      end
    else
      sort.to_s.split('_').first.to_sym
    end
  end

  def sort_types
    sorts = if search_by_location?
              [:distance, :rating]
            elsif search_by_name?
              [:relevance, :rating]
            else
              [:rating]
            end
    if filtering_search?
      sorts + [:fit]
    else
      sorts
    end
  end

  def sorting_by_fit?
    @active_sort == :fit
  end

  def sort_by_fit(school_results, direction)
    # Stable sort. See https://groups.google.com/d/msg/comp.lang.ruby/JcDGbaFHifI/2gKpc9FQbCoJ
    n = 0
    school_results.sort_by! {|x| n += 1; [((direction == :fit_asc) ? x.fit_score : (0-x.fit_score)), n]}
  end

  def parse_sorts(params_hash)
    params_hash['sort'].to_sym if params_hash.include?('sort') && !params_hash['sort'].instance_of?(Array) && SORT_TYPES.include?(params_hash['sort'])
  end
end
