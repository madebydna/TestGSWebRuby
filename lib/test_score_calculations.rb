module TestScoreCalculations

  def max_year
    @_max_year ||= map { |tds| tds['date_valid']&.to_date&.year }.compact.max
  end

  def select_items_with_max_year
    year = max_year
    select { |tds| tds['date_valid']&.to_date&.year == year }
  end

  def select_items_with_max_year!(*args)
    replace(select_items_with_max_year(*args))
  end

end
