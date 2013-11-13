module ApplicationHelper

  def category_placement_anchor(category_placement)
    category_placement.category.code_name
  end

  def category_placement_title(category_placement)
    category_placement.title || category_placement.category.name
  end

  def draw_stars_16(on_star_count)
    off_star_count = 5 - on_star_count
    class_on = 'iconx16-stars i-16-orange-star  i-16-star-' + on_star_count.to_s + ' fl'
    class_off = 'iconx16-stars i-16-grey-star  i-16-star-' + off_star_count.to_s + ' fl'
    content_tag(:div, '', :class => class_on)  +
        content_tag(:div, '', :class => class_off)
  end

  def write_review_count text_s
    write_s = ''
    if @school_reviews_global.review_filter_totals.all != 1
      write_s = 's'
    end
    @school_reviews_global.review_filter_totals.all.to_s + ' ' + text_s + write_s
  end

  def to_bar_chart_array(data_hash)
    @bar_chart_data = [['year', 'This school', 'State average']] + data_hash.collect.with_index { |(key, value), index|
      [key.to_s, value["score"], index == data_hash.size-1 ? value["state_avg"] : 0]
    }
  end

  def generate_img_path ( img_size, media_hash )
    comm_media_prefix = "library/"
    ENV_GLOBAL['media_server'] + comm_media_prefix + "school_media/" + @school.state.downcase + "/" + media_hash[0,2] + "/" + media_hash + "-"+img_size +".jpg"
  end

  def youtube_parse_id (video_str, youtube_match_string)
    youtube_id = video_str.split(youtube_match_string)[1].split('&')[0]
  end
  # This is used to include the video asset, for the school, only if it is a youtube link, then adds it to the lightbox.
  def include_lightbox_youtube_video (video_str)
    youtube_match_string = "youtube.com/watch?v="
    r_str = ''
    if video_str && video_str != ''
      if video_str.include? youtube_match_string
        youtube_id = video_str.split(youtube_match_string)[1].split('&')[0]
        r_str <<  '<a href="https://www.youtube.com/watch?v=' + youtube_id + '">'  + "\n"
        r_str <<  '<img ' + "\n"
        r_str <<  'src="https://img.youtube.com/vi/' + youtube_id + '/0.jpg"'
        r_str <<  'data-big="https://img.youtube.com/vi/' + youtube_id + '/2.jpg"'
        r_str <<  'data-title=""'
        r_str <<  'data-description=""'
        r_str <<  '>'
        r_str <<  '</a>'
      end
      return r_str.html_safe
    end
  end

  # This is used to include all the media assets for a school to the lightbox.
  def include_lightbox_media (media_hash)
    r_str = ''
    if media_hash
      #debugger

      media_hash.each { | x  |
        if media_hash
          r_str <<  '<a href="' + generate_img_path("500", x["hash"])  + '">' + "\n"
          r_str <<  '<img '
          r_str <<  'src="' + generate_img_path("130", x["hash"]) + '",' + "\n"
          r_str <<  'data-big="'+  generate_img_path("500", x["hash"]) +'"'  + "\n"
          r_str <<  'data-title=""' + "\n"
          r_str <<  'data-description="" >'  + "\n"
          r_str <<  '</a>' + "\n"
        end
      }

      return r_str.html_safe
    end
  end

  def serialize_param(path)
    path.gsub(/\s+/, '-')
  end

  def school_params(school)
    {
      state: serialize_param(school.state_name.downcase),
      city: serialize_param(school.city.downcase),
      schoolId: school.id,
      school_name: serialize_param(school.name.downcase)
    }
  end



  def urlSafeBase64Decode(base64String)
    return Base64.decode64(base64String.tr('-_','+/'))
  end

  def urlSafeBase64Encode(raw)
    return Base64.encode64(raw).tr('+/','-_')
  end

  def google_formatted_street_address
    address = @school.street+","+@school.city+","+@school.state+"+"+@school.zipcode
    address.gsub!(/\s+/,'+')
  end
  def sign_url(url)

    # TODO move to global variable definition config file
    # GOOGLE_PRIVATE_KEY = "ROnVnbh8o4tmlpgnSXDTu2DAWQU="
    # GOOGLE_CLIENT_ID = "gme-greatschoolsinc"

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
