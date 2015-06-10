require './app/models/presenters/topnav'
require 'open-uri'


module ApplicationHelper
  include CookieConcerns

  # Hack: Remove /assets/ prefix since it is set that way in hub_config
  # And needs to remain until hubs are off of Java
  def image_tag(path, *args, &blk)
    path = path.gsub('/assets/', '') if path.match(/hubs/i)
    super(path, *args, &blk)
  end

  def category_placement_anchor(category_placement)
    "#{category_placement_title category_placement}".gsub(/\W+/, '_')
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

  def generate_img_path(img_size, media_hash)
    comm_media_prefix = "library/"
    ENV_GLOBAL['media_server'] + '/' + comm_media_prefix + "school_media/" + @school.state.downcase + "/" + media_hash[0,2] + "/" + media_hash + "-#{img_size}.jpg"
  end

  def school_video_hashes(*args)
    args.compact.map do |video_str|
      if (youtube_parse_id_from_str(video_str)).present?
        id = youtube_parse_id_from_str(video_str)
        {type: :youtube, id: id} if id.present?


      # TODO: move media gallery to front end to show vimeo. Cannot do vimeo API calls from the server right now.
      # elsif (vimeo_parse_id_from_str(video_str)).present?
      #   id = vimeo_parse_id_from_str(video_str)
      #   {type: :vimeo, id: id} if id.present?
      end
    end.compact
  end

  def include_lightbox_school_video(video_source)
    return unless video_source.present?

    return include_lightbox_youtube_video(video_source[:id]) if video_source[:type] == :youtube
    # send("include_lightbox_#{video_source[:type]}_video", video_source[:id]) if video_source.present?
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

  # def vimeo_parse_id_from_str(video_str)
  #   if video_str.present?
  #     vimeo_match_string = 'vimeo.com/'
  #     video_str.split(vimeo_match_string)[1].split('/')[-1] if video_str.include?(vimeo_match_string)
  #   end
  # end

  # This is used to include the video asset, for the school, only if it is a youtube link, then adds it to the lightbox.
  def include_lightbox_youtube_video (youtube_id)
    r_str= ''
    if youtube_id.present?
        r_str <<  '<a href="https://www.youtube.com/watch?v=' + youtube_id + '">'  + "\n"
        r_str <<  '<img ' + "\n"
        r_str <<  'src="https://img.youtube.com/vi/' + youtube_id + '/0.jpg"'
        r_str <<  'data-big="https://img.youtube.com/vi/' + youtube_id + '/2.jpg"'
        r_str <<  'data-title=""'
        r_str <<  'data-description=""'
        r_str <<  '>'
        r_str <<  '</a>'

      return r_str.html_safe
    end
  end

  # def include_lightbox_vimeo_video(vimeo_id)
  #   r_str= ''
  #   if vimeo_id.present?
  #     r_str << '<a href="https://vimeo.com/' + vimeo_id + '">' + "\n"
  #     r_str << '<img src ="'+ vimeo_lightbox_thumbnail(create_vimeo_api_url(vimeo_id)) + '"'
  #     r_str << 'style="height:40px; width:40px"' + '/>'
  #     r_str << '</a>'
  #   end
  #
  #   return r_str.html_safe
  # end

  # This is used to include all the media assets for a school to the lightbox.
  def include_lightbox_media (school)
    media_hash = school.school_media
    r_str = ''
    if media_hash
      media_hash.each { | x  |
        if media_hash
          r_str <<  '<a href="' + school_media_image_path(school.state, "500", x["hash"])  + '">' + "\n"
          r_str <<  '<img '
          r_str <<  'src="' + school_media_image_path(school.state, "130", x["hash"]) + '",' + "\n"
          r_str <<  'data-big="'+  school_media_image_path(school.state, "500", x["hash"]) +'"'  + "\n"
          r_str <<  'data-title=""' + "\n"
          r_str <<  'data-description="" >'  + "\n"
          r_str <<  '</a>' + "\n"
        end
      }

      return r_str.html_safe
    end
  end

  # def vimeo_lightbox_thumbnail(vimeo_api_url)
  #   begin
  #     parsed_vimeo_json = JSON.parse(open(vimeo_api_url).read)
  #     img_url = parsed_vimeo_json['thumbnail_url']
  #     img_url.to_s
  #   rescue => error
  #     error.presence || ["An error occured with creating vimeo api url"]
  #   end
  # end

  # def create_vimeo_api_url(vimeo_id)
  #    "https://vimeo.com/api/oembed.json?url=https%3A//vimeo.com/#{vimeo_id}"
  # end

  def state_partial ( state )
    # case state
    # when "MI"
    #   return_partial = "shared/rating/draw_rect_72x58_rating"
    # else
      return_partial = "shared/rating/default_rating"
    # end
    # return_partial
  end

  def rating_partial_for_snapshot ( state )
    # case state
    # when "MI"
    #   return_partial = "shared/rating/snapshot/draw_rect_72x58_rating"
    # else
      return_partial = "shared/rating/snapshot/default_rating"
    # end
    # return_partial
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
    # TODO share code with application_controller::set_cafemom_ip_value
     request.env['X_Forwarded_For'] || request.env['X_CLUSTER_CLIENT'] || request.remote_ip
  end
  
  def zillow_url(school)
    # test that values needed are populated
    "http://www.zillow.com/#{States.abbreviation(school.state).upcase}-#{school.zipcode}?cbpartner=Great+Schools&utm_source=Great_Schools&utm_medium=referral&utm_campaign=#{(zillow_tracking_hash[action_name].present? ? zillow_tracking_hash[action_name] : 'gstrackingpagefail')}"
  end

  def zillow_tracking_hash
        hash = {
            'overview' => 'localoverview',
            'reviews' => 'localreviews',
            'quality' => 'localquality',
            'details' => 'localdetails',
            'city_browse' => 'schoolsearch',
            'district_browse' => 'schoolsearch',
            'search' => 'schoolsearch',
            'show' => 'schoolsearch'
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

  def topnav(school, hub = nil)
    TopNav.new(school, cookies, hub)
  end

  def search_by_location?
    @by_location
  end

  def search_by_name?
    @by_name
  end

  def filtering_search?
    @filtering_search
  end

  def guided_search_path(hub)
    state_url_name = gs_legacy_url_encode(States.state_name(hub.state))
    if hub.city
      "/#{state_url_name}/#{gs_legacy_url_city_district_browse_encode(hub.city)}/guided-search"
    else
      "/#{state_url_name}/guided-search"
    end
  end

  # this is the single place to reference naming for school type
  def school_type_display(type)
    school_types_map = {
        charter: 'Public charter',
        public: 'Public district',
        private: 'Private'
    }
    school_types_map[type.to_s.downcase.to_sym]
  end
end
