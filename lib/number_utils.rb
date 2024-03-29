module NumberUtils
  def faster_number_with_precision(number, precision = 1)
    p = 10 ** precision
    ((number * p) + 0.5).to_i.to_f / p
  end
end