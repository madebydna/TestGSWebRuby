module ApplicationHelper


  def category_placement_anchor(category_placement)
    "#{category_placement_title category_placement}-#{category_placement.id}".gsub(/\W+/, '_')
  end

  def category_placement_title(category_placement)
    category_placement.title || category_placement.category.name
  end


  def draw_stars_16(on_star_count)
    off_star_count = 5 - on_star_count
    class_on = 'iconx16-stars i-16-orange-star  i-16-star-' + on_star_count.to_s + ''
    class_off = 'iconx16-stars i-16-grey-star  i-16-star-' + off_star_count.to_s + ''
    content_tag(:span, '', :class => class_on)  +
        content_tag(:span, '', :class => class_off)
  end

  def draw_stars_24(on_star_count)
    off_star_count = 5 - on_star_count
    class_on = 'iconx24-stars i-24-orange-star  i-24-star-' + on_star_count.to_s + ''
    class_off = 'iconx24-stars i-24-grey-star  i-24-star-' + off_star_count.to_s + ''
    content_tag(:span, '', :class => class_on)  +
        content_tag(:span, '', :class => class_off)
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
      [key.to_s, value["score"], index == 0 ? value["state_avg"] : 0]
    }
  end

  def to_bar_chart_review_array(star_counts)
    [
      ['Star Count', 'count'],
      ['5 stars',  star_counts[5]],
      ['4 stars',  star_counts[4]],
      ['3 stars',  star_counts[3]],
      ['2 stars',  star_counts[2]],
      ['1 stars',  star_counts[1]]
    ]
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


  # In this method, capitalize means to uppercase the first letter of a phrase and leave the rest untouched.
  # Default implementation of capitalize in rails will uppercase first letter and downcase the rest of the string
  def capitalize_if_string(object)
    if object.is_a? String
      object.gs_capitalize_first
    else
      object
    end
  end

  def category_placement_data(category_placement)
    @data_cache ||= {}
    @data_cache[category_placement] ||= category_placement.category.data_for_school(@school)
  end

  def log_view_error(message, e)
    Rails.logger.debug "#{message}: #{e}"
    if Rails.application.config.consider_all_requests_local
      render inline: '<div class="row"><strong>' + message + '</strong></div>'
    end
  end

  def render_array_horizontally(input_array, max_array)
    min_size = 12 / input_array.size
    size_str = ''
    max_array.each do |key, value|
      sizing_str = min_size
      if min_size < value
        sizing_str = value
      end
      size_str << ' col-'+key.to_s+'-'+sizing_str.to_s
    end
    output = ""
    input_array.each_with_index do | value, index |
      output << "<div class='"+size_str+"'>"+value+"</div>"
    end
    output
  end

  # When passed a content string or a block, adds that content to an array, which will get uniqued before being
  # displayed
  # If the layout erb file asks for unique_content_for(:blah) without passing content or block, then the uniqued
  # content will be returned
  def unique_content_for(name, content = nil, &block)
    @content_array ||= {}
    if content || block_given?
      content = capture(&block) if block_given?
      @content_array[name] ||= []
      @content_array[name] << content if content
      nil
    else
      raw (@content_array[name] || []).uniq.join
    end
  end

end
