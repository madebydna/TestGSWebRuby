module CityHubHelper
  def abbreviate_at_whitespace(string, max_length)
    if max_length > 2
      unless string.blank?
        string.strip!
        if string.length > max_length
          ind = string.rindex(' ', max_length)
          ind = max_length if ind.nil?
          string = string[0..ind]
          end_of_sentence_regex = /.*[\\.\\?\\!]$/
          unless end_of_sentence_regex.match(string)
            if string.length > max_length - 3
              ind2 = string.rindex(' ', string.length - 3)
              ind2 = string.length - 3 if ind2.nil?
              string = string[0..ind2]
            end
            unless end_of_sentence_regex.match(string)
              string = string.strip + '...'
            end
          end
        end
      end
      return string
    else
      raise ArgumentError.new("max_length my be > 2; now: #{max_length}")
    end
  end
end
