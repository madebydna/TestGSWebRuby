module GradeLevelConcerns

# need to find contiguous grade levels and insert a dash "-" between first and last
# pre K or PK is smallest
# KG or K is second smallest - convert KG to K
# Breaks in grade sequence is separated by a comma
# UG if alone will be written as Ungraded if at the end of a series append as "& Ungraded"
  def process_level
    level.is_a?(String) ? level_array = level.split(',') : level_array = level
    if level_array.blank?
      return nil
    end

    if level_array.length == 1
      if level_array[0] == 'KG'
        return 'K'
      elsif level_array[0] == 'UG'
        return 'Ungraded'
      end
      return level_array[0]
    end

    # some prep of array and detect ungraded
    ungraded = false
    level_array.each_with_index do | value, index |
      if (value == 'KG')
        level_array[index] = 'K'
      elsif (value == 'UG' )
        ungraded = true
      end
    end

    return_str = ''

    temp_array = ['PK','K','1','2','3','4','5','6','7','8','9','10','11','12']
      .map { |i| (level_array.include? i.to_s) ? i : '|' }
      .join(' ')
      .split('|')
      .each{|obj| obj.strip!}
      .reject(&:empty?)

    temp_array.each_with_index do |value, index|
      if index != 0
        return_str += ', '
      end
      inner_array = value.split(' ')
      return_str += inner_array.first
      if inner_array.length > 1
        # use first and last with dash
        return_str += '-' + inner_array.last
      end
    end

    if ungraded == true
      return_str += " & Ungraded"
    end
    return_str
  end

  def description
    snippet ||= %Q{#{name} is a #{type} school} unless name.empty? || type.empty?
    if snippet
      snippet << %Q{ that serves #{levels_description}} unless levels_description.nil?
      snippet << %Q{. It has received a GreatSchools rating of #{great_schools_rating} out of 10 based on academic quality.} unless great_schools_rating.nil?
    end
    snippet.presence
  end

  def great_schools_rating
    school_metadata[:overallRating].presence
  end

  def levels_description
    levels = process_level
    if levels.nil? || levels.include?('Ungraded')
      nil
    else
      levels.length > 2 ? "grades #{levels}" :  "grade #{levels}"
    end
  end
end