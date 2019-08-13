module TestScoreCalculations

  def max_year
    @_max_year ||= begin
      map(&method(:extract_year)).compact.max
    end
  end

  def extract_year(tds)
    tds['date_valid']&.to_date&.year
  rescue ArgumentError, NoMethodError
    0
  end

  def select_items_with_max_year
    select { |tds| (extract_year(tds)) == max_year }
  end

  def select_items_with_max_year!(*args)
    replace(select_items_with_max_year(*args))
  end

end