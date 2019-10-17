module NumberToWord

  def self.human_readable_number(value)
    number = NumberToWord.to_whole_number(value, '.')
    return "#{NumberToWord.convert_number(number)} #{NumberToWord.denomination(number)}".strip
    
    nil
  end

  private

  def self.to_whole_number(value, delimiter)
    validNumbers = /^[0-9]+$/
    number_set = value.to_s.split(delimiter)

    return number_set.first if number_set.length < 3 && validNumbers.match(number_set[0])
    raise(ArgumentError, "#{value} is not a valid number")
  end

  def self.convert_number(number)
    num_length = number.length
    truncated, fraction = nil

    case
    when num_length > 12
      truncated = number[0...num_length - 12]
      fraction = number[truncated.length]
    when num_length > 9
      truncated = number[0...num_length - 9]
      fraction = number[truncated.length]
    when num_length > 6
      truncated = number[0...num_length - 6]
      fraction = number[truncated.length]
    when num_length > 3
      truncated = number[0...num_length - 3]
      fraction = number[truncated.length]
    else
      truncated = number;
    end

    NumberToWord.insert_decimal(truncated, fraction)
  end

  def self.insert_decimal(number, fraction)
    return "#{number}.#{fraction}" if fraction
    number
  end

  def self.denomination(value)
    case
    when value.length > 12
      return I18n.t('trillion', scope: 'modules.number_to_word')
    when value.length > 9
      return I18n.t('billion', scope: 'modules.number_to_word')
    when value.length > 6
      return I18n.t('million', scope: 'modules.number_to_word')
    when value.length > 3
      return I18n.t('thousand', scope: 'modules.number_to_word')
    else
      return ''
    end
  end

end