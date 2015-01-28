class GoogleSignedImages
  STREET_VIEW_URL = 'http://maps.googleapis.com/maps/api/streetview'
  STATIC_MAP_URL =  'http://maps.googleapis.com/maps/api/staticmap'

  def self.street_view_url(height, width, address)
    url = STREET_VIEW_URL.clone
    url << "?fov=70"
    url << "&size=#{height}x#{width}"
    url << "&location=#{address}"
    url << "&sensor=false"
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
    google_private_key = ENV_GLOBAL['GOOGLE_PRIVATE_KEY']
    google_client_id = ENV_GLOBAL['GOOGLE_CLIENT_ID']

    parsed_url = URI.parse(URI.encode(url))
    url_to_sign = parsed_url.path + '?' + parsed_url.query + '&client=' + google_client_id

    # Decode the private key
    raw_key = url_safe_base64_decode(google_private_key)

    # create a signature using the private key and the URL
    sha1 = HMAC::SHA1.new(raw_key)
    sha1 << url_to_sign
    raw_signature = sha1.digest

    # encode the signature into base64 for url use form.
    signature =  url_safe_base64_encode(raw_signature)

    # prepend the server and append the signature.
    signed_url = parsed_url.scheme+"://"+ parsed_url.host + url_to_sign + "&signature=#{signature}"
  end
end

