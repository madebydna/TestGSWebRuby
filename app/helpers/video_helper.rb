module VideoHelper
  # def generate_img_path(img_size, media_hash)
  #   comm_media_prefix = "library/"
  #   ENV_GLOBAL['media_server'] + '/' + comm_media_prefix + "school_media/" + @school.state.downcase + "/" + media_hash[0,2] + "/" + media_hash + "-#{img_size}.jpg"
  # end

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
      (youtube_id = video_str.split(youtube_match_string_1)[1].split(/['?', '&']/)[0]) if video_str.include?(youtube_match_string_1)
      (youtube_id = video_str.split(youtube_match_string_2)[1].split(/['?', '&']/)[0]) if video_str.include?(youtube_match_string_2)

    end

    youtube_id
  end

  # This is used to include the video asset, for the school, only if it is a youtube link, then adds it to the lightbox.
  def include_lightbox_youtube_video (youtube_id)
    r_str= ''
    if youtube_id.present?
      r_str << '<a href="https://www.youtube.com/watch?v=' + youtube_id + '">' + "\n"
      r_str << '<img ' + "\n"
      r_str << 'src="https://img.youtube.com/vi/' + youtube_id + '/0.jpg"'
      r_str << 'data-big="https://img.youtube.com/vi/' + youtube_id + '/2.jpg"'
      r_str << 'data-title=""'
      r_str << 'data-description=""'
      r_str << '>'
      r_str << '</a>'

      return r_str.html_safe
    end
  end

  # This is used to include all the media assets for a school to the lightbox.
  def include_lightbox_media (school)
    media_hash = school.school_media
    r_str = ''
    if media_hash
      media_hash.each { |x|
        if media_hash
          r_str << '<a href="' + school_media_image_path(school.state, "500", x["hash"]) + '">' + "\n"
          r_str << '<img '
          r_str << 'src="' + school_media_image_path(school.state, "130", x["hash"]) + '",' + "\n"
          r_str << 'data-big="'+ school_media_image_path(school.state, "500", x["hash"]) +'"' + "\n"
          r_str << 'data-title=""' + "\n"
          r_str << 'data-description="" >' + "\n"
          r_str << '</a>' + "\n"
        end
      }

      return r_str.html_safe
    end
  end

  def state_partial (state)
    # case state
    # when "MI"
    #   return_partial = "shared/rating/draw_rect_72x58_rating"
    # else
    return_partial = "shared/rating/default_rating"
    # end
    # return_partial
  end

  def rating_partial_for_snapshot (state)
    # case state
    # when "MI"
    #   return_partial = "shared/rating/snapshot/draw_rect_72x58_rating"
    # else
    return_partial = "shared/rating/snapshot/default_rating"
    # end
    # return_partial
  end

  ########################################################################################################################
  #
  # Vimeo code - not sure if it was ever used
  #
  #######################################################################################################################

  # def vimeo_parse_id_from_str(video_str)
  #   if video_str.present?
  #     vimeo_match_string = 'vimeo.com/'
  # todo need to make sure this still works w/ url params
  #     video_str.split(vimeo_match_string)[1].split('/')[-1] if video_str.include?(vimeo_match_string)
  #   end
  # end

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
end