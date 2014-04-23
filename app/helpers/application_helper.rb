require './app/models/presenters/topnav'

module ApplicationHelper
  include CookieConcerns

  def category_placement_anchor(category_placement)
    "#{category_placement_title category_placement}-#{category_placement.id}".gsub(/\W+/, '_')
  end

  def category_placement_title(category_placement)
    category_placement.title || category_placement.category.name
  end

  def draw_stars(size, on_star_count)
    off_star_count = 5 - on_star_count
    class_on  = "iconx#{size}-stars i-#{size}-orange-star i-#{size}-star-#{on_star_count}"
    class_off = "iconx#{size}-stars i-#{size}-grey-star i-#{size}-star-#{off_star_count}"
    content_tag(:span, '', :class => class_on) + content_tag(:span, '', :class => class_off)
  end

  def draw_stars_16(on_star_count)
    draw_stars 16, on_star_count
  end

  def draw_stars_24(on_star_count)
    draw_stars 24, on_star_count
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
      #Display the state average only for the latest year.
      #The google bar chart requires it be a numerical value.
      #Hence set default to 0(This also catches the case when there is no data for state average ie. value['state_avg']= nil).
      state_value = 0
      if index == 0 && !value["state_avg"].nil?
        state_value = value["state_avg"]
      end
      [key.to_s, value["score"], state_value]
    }
  end

  def to_bar_chart_review_array(star_counts)
    [
      ['Star Count', 'count'],
      ['5 stars',  star_counts[5]],
      ['4 stars',  star_counts[4]],
      ['3 stars',  star_counts[3]],
      ['2 stars',  star_counts[2]],
      ['1 star',  star_counts[1]]
    ]
  end

  def generate_img_path ( img_size, media_hash )
    comm_media_prefix = "library/"
    ENV_GLOBAL['media_server'] + '/' + comm_media_prefix + "school_media/" + @school.state.downcase + "/" + media_hash[0,2] + "/" + media_hash + "-"+img_size +".jpg"
  end

  def youtube_parse_id (video_str, youtube_match_string)
    youtube_id = video_str.split(youtube_match_string)[1].split('&')[0]
  end

  def youtube_parse_id_from_str (video_str)
    # match string one
    youtube_id = nil

    if video_str.present?
      youtube_match_string_1 = "youtube.com/watch?v="
      youtube_match_string_2 = "youtu.be/"
      (youtube_id = video_str.split(youtube_match_string_1)[1].split('&')[0]) if video_str.include?(youtube_match_string_1)
      (youtube_id = video_str.split(youtube_match_string_2)[1].split('&')[0]) if video_str.include?(youtube_match_string_2)

    end

    youtube_id
  end

  # This is used to include the video asset, for the school, only if it is a youtube link, then adds it to the lightbox.
  def include_lightbox_youtube_video (video_str)
    r_str= ''
    youtube_id = youtube_parse_id_from_str(video_str)
    if youtube_id.present?
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

  # This is used to include all the media assets for a school to the lightbox.
  def include_lightbox_media (media_hash)
    r_str = ''
    if media_hash
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

  def state_partial ( state )
    case state
    when "MI"
      return_partial = "shared/rating/draw_rect_72x58_rating"
    else
      return_partial = "shared/rating/default_rating"
    end
    return_partial
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

  def category_placement_data(page_config, category_placement)
    @data_cache ||= {}
    if category_placement.category
      @data_cache[category_placement] ||= @school.data_for_category category: category_placement.category
    end
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

  def remote_ip
    request.env['HTTP_X_FORWARDED_FOR'] || request.remote_ip
  end

  def breadcrumb_hash
    {
        'Home' => home_url,
        hub_params[:state].gsub(/-/, ' ').gs_capitalize_words => state_url(state: hub_params[:state]),
        hub_params[:city].gsub(/-/, ' ').gs_capitalize_words => city_url(hub_params)
    }
  end

  def zillow_url(school)
    # test that values needed are populated
    zillow = ''
    zillow << 'http://www.zillow.com/'
    zillow << States.abbreviation(school.state).upcase
    zillow << '-'+school.zipcode
    zillow << '?cbpartner=GreatSchools&utm_source=GreatSchools&utm_medium=referral&utm_campaign='
    zillow << (zillow_tracking_hash[action_name].present? ? zillow_tracking_hash[action_name] : 'gstrackingpagefail')
  end

  def zillow_tracking_hash
        hash = {
            'overview' => 'localoverview',
            'reviews' => 'localreviews',
            'quality' => 'localquality',
            'details' => 'localdetails'
        }

  end

  def column_sizing_classes(xs, sm, md, lg)
    " col-xs-#{xs} col-sm-#{sm} col-md-#{md} col-lg-#{lg}"
  end

  def content_tag_with_sizing(name, *args, &block)
    # The inner content of the tag depends on whether or not a block is given.
    # If content of the tag is the first item, the options will be second
    args.unshift nil if args.first && args.first.is_a?(Hash)
    options = args.second || {}

    if options[:sizes]
      default_sizing = { xs: 12, sm: 12, md: 12, lg: 12 }
      sizing = (options[:sizes] || {}).reverse_merge! default_sizing
      options.delete :sizes
      sizing_class = self.column_sizing_classes(sizing[:xs], sizing[:sm], sizing[:md], sizing[:lg])
      options[:class] ||= ''
      options[:class] << sizing_class
    end

    content_tag name, *args, &block
  end

  def div_tag(*args, &block)
    content_tag_with_sizing :div, *args, &block
  end

  def topnav_formatted_title(school, hub_params)
    TopNav.new(school, hub_params, cookies).formatted_title
  end
end
