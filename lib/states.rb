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
    return name_or_abbreviation.upcase if name_or_abbreviation.size == 2

    return state_hash[name_or_abbreviation]
  end

  def self.state_name(abbreviation)
    abbreviation_hash[abbreviation]
  end

  def self.any_state_name_regex
    regex = ''
    state_hash.keys.each {|s| regex << ("#{s}|".downcase.gsub(/\s+/, '-')) }
    regex = regex[0..-2]
    return Regexp.new regex, 'i'
  end

  # lowercased array of state abbreviations as symbols
  def self.abbreviations_as_symbols
    state_hash.values.map{ |state| state.downcase.to_sym }
  end
end