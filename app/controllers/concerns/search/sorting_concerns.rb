module SortingConcerns
  extend ActiveSupport::Concern

  protected

  SORT_TYPES = ['rating_desc', 'fit_desc', 'distance_asc']
  DEFAULT_SORT = :rating_desc

  def active_sort_name(sort)
    if sort
      sort.to_s.split('_').first.to_sym
    else
      # By name sorting is just solr's default, aka. there is no sort
      # For display, we call this relevance
      :relevance
    end
  end

  def sort_types(hide_fit)
    sorts = if search_by_location?
              [:distance, :rating]
            elsif search_by_name?
              [:relevance, :rating]
            else
              [:rating]
            end

    (filtering_search? && !hide_fit) ? sorts + [:fit] : sorts
  end

  def sorting_by_fit?
    @active_sort == :fit
  end

  def sort_by_fit(school_results)
    # Stable sort. See https://groups.google.com/d/msg/comp.lang.ruby/JcDGbaFHifI/2gKpc9FQbCoJ
    n = 0
    school_results.sort_by! {|x| n += 1; [0-x.fit_ratio, n]}
  end

  def parse_sorts(params_hash)
    default_sort = search_by_name? ? nil : DEFAULT_SORT # The default by_name sort is no sort
    sort_types = Hash.new(default_sort).merge(
        {
            rating_desc: :rating_desc,
            fit_desc: :fit_desc,
            distance_asc: :distance_asc
        }.stringify_keys
    )
    sort_types[params_hash['sort']]
  end
end
