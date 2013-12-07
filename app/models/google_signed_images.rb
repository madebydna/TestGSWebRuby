class GoogleSignedImages
 attr_accessor :school, :gon
  def initialize (school, gon)
    self.school = school
    self.gon = gon
    createSizedMaps
  end

  def urlSafeBase64Decode(base64String)
    return Base64.decode64(base64String.tr('-_','+/'))
  end

  def urlSafeBase64Encode(raw)
    return Base64.encode64(raw).tr('+/','-_')
  end

  def google_formatted_street_address
    address = school.street+","+school.city+","+school.state+"+"+school.zipcode
    address.gsub!(/\s+/,'+')
  end

  def createSizedMaps
    google_apis_path = 'http://maps.googleapis.com/maps/api/staticmap'
    address = google_formatted_street_address

    sizes = {
        'sm' => [280, 280],
        'md' => [400, 200],
        'lg' => [500, 200]
    }

    gon.contact_map ||= sizes.inject({}) do |sized_maps, element|
      label = element[0]
      size = element[1]
      sized_maps[label] = sign_url("#{google_apis_path}?size=#{size[0]}x#{size[1]}&center=#{address}&markers=#{address}&sensor=false")
      sized_maps
    end
  end

  def sign_url(url)

    google_private_key = ENV_GLOBAL['GOOGLE_PRIVATE_KEY']
    google_client_id = ENV_GLOBAL['GOOGLE_CLIENT_ID']

    parsed_url = URI.parse(url)
    url_to_sign = parsed_url.path + '?' + parsed_url.query + '&client=' + google_client_id

    # Decode the private key
    rawKey = urlSafeBase64Decode(google_private_key)

    # create a signature using the private key and the URL
    sha1 = HMAC::SHA1.new(rawKey)
    sha1 << url_to_sign
    raw_signature = sha1.digest()

    # encode the signature into base64 for url use form.
    signature =  urlSafeBase64Encode(raw_signature)

    # prepend the server and append the signature.
    signed_url = parsed_url.scheme+"://"+ parsed_url.host + url_to_sign + "&signature=#{signature}"
    return signed_url
  end
end

