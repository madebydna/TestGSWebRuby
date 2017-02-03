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
    if str.size == 2 && abbreviation_hash.include?(str)
      return str
    end

    return state_hash[str]
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

  # this is for preserving url structure of Districts/Cities list SEO page urls
  def self.any_state_name_regex_titleize
    regex = ''
    state_hash.keys.each do |s|
      if s == 'washington dc'
        regex << ('Washington_DC|')
      else
        regex << ("#{s}|".titleize.gsub(/\s+/, '_'))
      end
    end
    regex = regex[0..-2]
    return Regexp.new regex
  end

  # this is for preserving url structure of Districts/Cities list SEO page urls
  def self.any_state_abbreviation_regex_without_anchors
    regex = ''
    regex << state_hash.values.map{|s| s.upcase }.join('|')
    return Regexp.new regex
  end

  def self.abbreviations
    abbreviation_hash.keys.sort
  end

  def self.abbr_to_label(state_abbr)
    labels_hash[state_abbr]
  end

  def self.labels_hash
    labels_hash = {}
    STATE_HASH.invert.each do |k,v|
      k == "dc" ? labels_hash[k] = "Washington DC" : labels_hash[k] = v.titleize
    end
    labels_hash
  end
end
