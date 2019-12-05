module States
  # Note: order of items in hash matters, because when it is inverted, dc will map to washington dc
  STATE_HASH = {
    'alabama' => 'al',
    'alaska' => 'ak',
    'arizona' => 'az',
    'arkansas' => 'ar',
    'california' => 'ca',
    'colorado' => 'co',
    'connecticut' => 'ct',
    'delaware' => 'de',
    'district of columbia' => 'dc',
    'washington dc' => 'dc',
    'florida' => 'fl',
    'georgia' => 'ga',
    'hawaii' => 'hi',
    'idaho' => 'id',
    'illinois' => 'il',
    'indiana' => 'in',
    'iowa' => 'ia',
    'kansas' => 'ks',
    'kentucky' => 'ky',
    'louisiana' => 'la',
    'maine' => 'me',
    'maryland' => 'md',
    'massachusetts' => 'ma',
    'michigan' => 'mi',
    'minnesota' => 'mn',
    'mississippi' => 'ms',
    'missouri' => 'mo',
    'montana' => 'mt',
    'nebraska' => 'ne',
    'nevada' => 'nv',
    'new hampshire' => 'nh',
    'new jersey' => 'nj',
    'new mexico' => 'nm',
    'new york' => 'ny',
    'north carolina' => 'nc',
    'north dakota' => 'nd',
    'ohio' => 'oh',
    'oklahoma' => 'ok',
    'oregon' => 'or',
    'pennsylvania' => 'pa',
    'rhode island' => 'ri',
    'south carolina' => 'sc',
    'south dakota' => 'sd',
    'tennessee' => 'tn',
    'texas' => 'tx',
    'utah' => 'ut',
    'vermont' => 'vt',
    'virginia' => 'va',
    'washington' => 'wa',
    'west virginia' => 'wv',
    'wisconsin' => 'wi',
    'wyoming' => 'wy'
  }

  def self.state_hash
    States::STATE_HASH
  end

  def self.abbreviation_hash
    @@rhash ||= state_hash.invert
  end

  def self.abbreviation(name_or_abbreviation)
    return if name_or_abbreviation.nil?
    str = name_or_abbreviation.downcase
    return str if is_abbreviation?(str)

    return state_hash[str]
  end

  def self.state_path(name)
    path = States.state_name(name)
    path.gsub(' ', '-') if path
  end

  def self.capitalize_any_state_names(string)
    return string if string.nil?
    regexp = Regexp.new('\b' << state_hash.keys.join('\b|\b') << '\b', 'i')
    titleized = string.gsub(regexp, &:titleize)
    string == "washington dc" ? "Washington DC" : titleized
  end

  def self.state_name(str)
    return nil unless str.present?
    str = str.downcase
    abbreviation_hash[str] || state_hash.keys.find { |obj| obj == str }
  end

  def self.any_state_name_regex
    regex = ''
    state_hash.keys.each {|s| regex << ("#{s}|".downcase.gsub(/\s+/, '\-')) }
    regex = regex[0..-2]
    return Regexp.new regex, 'i'
  end

  def self.any_state_abbreviation_regex
    regex = '\A'
    regex << state_hash.values.join('\z|\A')
    regex << '\z'
    return Regexp.new regex, 'i'
  end

  def self.route_friendly_any_state_abbreviation_regex
    regex = ''
    regex << state_hash.values.join('|')
    return Regexp.new regex, 'i'
  end

  def self.abbreviations
    abbreviation_hash.keys.sort
  end

  def self.abbr_to_label(state_abbr)
    labels_hash[state_abbr.downcase] if state_abbr.present?
  end

  def self.labels_hash
    labels_hash = {}
    STATE_HASH.invert.each do |k,v|
      k == "dc" ? labels_hash[k] = "Washington DC" : labels_hash[k] = v.titleize
    end
    labels_hash
  end

  def self.is_abbreviation?(string)
    abbreviation_hash.include?(string)
  end
end
