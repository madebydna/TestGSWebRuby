module ApiPagination
  def self.included(base)
    base.class_eval do
      # cattr_accessor here will create class getter/setters and instance
      # methods too
      cattr_accessor :pagination_max_limit, :pagination_default_limit, :pagination_items_proc
      attr_writer :pagination_max_limit
    end
  end

  # each controller class can set a global max limit, but each instance
  # of that controller might choose to override the max limit under certain
  # conditions
  def pagination_max_limit
    @pagination_max_limit || self.class.pagination_max_limit
  end

  def pagination_default_limit
    self.class.pagination_default_limit || 100
  end

  def offset
    params[:offset].to_i
  end

  def limit
    l = (params[:limit] || pagination_default_limit).to_i
    [l, pagination_max_limit].min
  end

  def first_page?
    offset.zero?
  end

  def last_page?
    items = instance_exec(&pagination_items_proc)
    items.size < limit
  end

  def previous_offset
    [offset - limit, 0].max if offset > 0
  end

  def next_offset
    items = instance_exec(&pagination_items_proc)
    offset + limit if items.size == limit
  end

  def prev
    unless first_page?
      url_for(request.params.merge(offset: previous_offset, limit: limit))
    end
  end

  def next
    unless last_page?
      url_for(request.params.merge(offset: next_offset, limit: limit))
    end
  end

end
