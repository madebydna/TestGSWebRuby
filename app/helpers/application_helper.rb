module ApplicationHelper

  def render_all_positions
    result = ''
    @category_positions.keys.sort.each { |position| result << String(render_position position) }
    result.html_safe
  end

  def render_position(position_number)
    if @category_positions[position_number]

      placement_and_data = @category_placements[position_number]
      return if placement_and_data.nil?

      category_placement = placement_and_data[:placement]
      category = category_placement.category
      data = placement_and_data[:data]

      # different layout for debugging. triggered via url param
      if params[:category_placement_debugging] && placement_and_data
        return render 'data_layouts/category_placement_debug',
          category_placements: @category_positions[position_number],
          picked_placement: placement_and_data[:placement],
          school: @school
      end

      # mark the Category itself as picked
      mark_category_layout_picked category_placement

      # figure out which partial to render
      partial = "data_layouts/#{category_placement.layout}"

      # build json object for layout config
      if category_placement.layout_config.present?
        # TODO: handle unparsable layout_config. Maybe try to parse it upon insert, so bad data can't get in db
        layout_config = category_placement.layout_config.gsub(/\t|\r|\n/, '').gsub(/[ ]+/i, ' ').gsub(/\\"/, '"')
        layout_config_json = {}.to_json
        layout_config_json = JSON.parse(layout_config) unless layout_config.nil? || layout_config == ''
      end

      # render the category data
      render 'module_container',
        partial:partial,
        category_placement:category_placement,
        data: data,
        category: category,
        config: category_placement.layout_config.present? ? TableConfig.new(layout_config_json) : nil,
        size: category_placement.size || 12

    end
  end

  def mark_category_layout_picked(placement)
    key = placement.page_category_layout_key
    @category_layouts_already_picked_by_a_position ||= []
    @category_layouts_already_picked_by_a_position << key
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
      [key.to_s, value.score, index == data_hash.size-1 ? value.state_avg : 0]
    }
  end

  def generate_img_path ( img_size, media_hash )
    # TODO move to global variable definition config file
    default_url = "http://dev.greatschools.org/"
    comm_media_prefix = "library/"
    default_url + comm_media_prefix + "school_media/" + @school.state.downcase + "/" + media_hash[0,2] + "/" + media_hash + "-"+img_size +".jpg"

  #${communityUtil.mediaPrefix}school_media/${schoolMedia.schoolState.abbreviationLowerCase}/${fn:substring(schoolMedia.hash,0,2)}/${schoolMedia.hash}-500.jpg"
    #alt="${schoolMedia.id}
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
    google_private_key = "ROnVnbh8o4tmlpgnSXDTu2DAWQU="
    google_client_id = "gme-greatschoolsinc"

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
