module TestScoreCalculations

  def max_year
    @_max_year ||= begin
      map do |tds|
        tds['date_valid'].is_a?(String) && Date.parsable?(tds['date_valid']) ? tds['date_valid']&.to_date&.year : 0
      end.compact.max
    end
  end

  def select_items_with_max_year
    year = max_year
    select { |tds| (tds['date_valid'].is_a?(String) && Date.parsable?(tds['date_valid']) ? tds['date_valid']&.to_date&.year : 0) == year }
  end

  def select_items_with_max_year!(*args)
    replace(select_items_with_max_year(*args))
  end

end


class Date
  def self.parsable?(string)
    begin
      parse(string)
      true
    rescue ArgumentError
      false
    end
  end
end