class GoogleSignedImages
  STREET_VIEW_URL = '//maps.googleapis.com/maps/api/streetview'
  STATIC_MAP_URL =  '//maps.googleapis.com/maps/api/staticmap'
  GOOGLE_MAPS_URL = '//www.google.com/maps/place/'

  def self.street_view_url(height, width, address)
    url = STREET_VIEW_URL.clone
    url << "?fov=70"
    url << "&size=#{height}x#{width}"
    url << "&location=#{address}"
    url << "&sensor=false"
  end

  def self.google_maps_url(address)
    GOOGLE_MAPS_URL + address
  end

  def self.url_safe_base64_decode(base64_string)
    Base64.decode64(base64_string.tr('-_','+/'))
  end

  def self.url_safe_base64_encode(raw)
    Base64.encode64(raw).tr('+/','-_')
  end

  def self.google_formatted_street_address(school)
    address = school.street+","+school.city+","+school.state+"+"+school.zipcode
    # We may want to look into CGI.escape() to prevent the chained gsubs
    address.gsub(/\s+/,'+').gsub(/'/,'')
  end

  def self.sign_url(url)
    google_api_key = ENV_GLOBAL['GOOGLE_MAPS_STATIC_API_KEY']
    signing_key = ENV_GLOBAL['GOOGLE_MAPS_STATIC_SIGNING_KEY']

    parsed_url = URI.parse(URI.encode(url))
    url_to_sign = parsed_url.path + '?' + parsed_url.query + '&key=' + google_api_key

    # Decode the private key
    raw_key = url_safe_base64_decode(signing_key)

    # create a signature using the private key and the URL
    sha1 = HMAC::SHA1.new(raw_key)
    sha1 << url_to_sign
    raw_signature = sha1.digest

    # encode the signature into base64 for url use form.
    signature =  url_safe_base64_encode(raw_signature)

    # prepend the server and append the signature.
    signed_url = parsed_url.scheme.present? ? parsed_url.scheme + '://' : '//'
    signed_url + parsed_url.host + url_to_sign + "&signature=#{signature}"
  end
end

