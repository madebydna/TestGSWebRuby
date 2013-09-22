module States
  def self.state_hash
    {
     'alabama' => 'AL',
     'alaska' => 'AK',
     'arizona' => 'AZ',
     'arkansas' => 'AR',
     'california' => 'CA',
     'colorado' => 'CO',
     'connecticut' => 'CT',
     'delaware' => 'DE',
     'district of columbia' => 'DC',
     'florida' => 'FL',
     'georgia' => 'GA',
     'hawaii' => 'HI',
     'idaho' => 'ID',
     'illinois' => 'IL',
     'indiana' => 'IN',
     'iowa' => 'IA',
     'kansas' => 'KS',
     'kentucky' => 'KY',
     'louisiana' => 'LA',
     'maine' => 'ME',
     'maryland' => 'MD',
     'massachusetts' => 'MA',
     'michigan' => 'MI',
     'minnesota' => 'MN',
     'mississippi' => 'MS',
     'missouri' => 'MO',
     'montana' => 'MT',
     'nebraska' => 'NE',
     'nevada' => 'NV',
     'new Hampshire' => 'NH',
     'new Jersey' => 'NJ',
     'new Mexico' => 'NM',
     'new York' => 'NY',
     'north Carolina' => 'NC',
     'north Dakota' => 'ND',
     'ohio' => 'OH',
     'oklahoma' => 'OK',
     'oregon' => 'OR',
     'pennsylvania' => 'PA',
     'rhode Island' => 'RI',
     'south Carolina' => 'SC',
     'south Dakota' => 'SD',
     'tennessee' => 'TN',
     'texas' => 'TX',
     'utah' => 'UT',
     'vermont' => 'VT',
     'virginia' => 'VA',
     'washington' => 'WA',
     'west Virginia' => 'WV',
     'wisconsin' => 'WI',
     'wyoming' => 'WY'}
  end

  def self.abbreviation(name_or_abbreviation)
    return name_or_abbreviation.upcase if name_or_abbreviation.size == 2

    return state_hash[name_or_abbreviation]
  end

  def self.any_state_name_regex
    regex = ''
    state_hash.keys.each {|s| regex << ("#{s}|".downcase.gsub(/\s+/, '-')) }
    regex = regex[0..-2]
    return regex
  end
end