module SharingTooltipModal
  SHARE_LINKS = [
      {icon: 'icon-mail', link_name: 'Email', link: 'mailto:'},
      {icon: 'icon-facebook', link_name: 'Facebook', link:'https://www.facebook.com/sharer/sharer.php?u='},  #, link: '"https://www.facebook.com/sharer/sharer.php?u=' + URLENCODED_URL + '&t=' + TITLE + '"'},
      {icon: 'icon-twitter', link_name: 'Twitter', link:'https://twitter.com/share?url='},  #, link: '"https://twitter.com/share?url=' + URLENCODED_URL + '&via=@GreatSchools&text=' + TEXT + '"'},
      {icon: 'icon-link', link_name: 'Permalink'},
      {icon: 'icon-share', link_name: 'SMS'}
  ]

  FACEBOOK_BASE_SHARE_URL = 'https://www.facebook.com/sharer/sharer.php?u='
  TWITTER_BASE_SHARE_URL = 'https://twitter.com/share?url='
  URLENCODED_URL = ''
  TITLE = ''
  TWITTER_HANDLE = ''
  TEXT = ''

  # https://www.greatschools.org/california/atherton/6951-Menlo-Atherton-High-School/?utm_source=profile&utm_medium=twitter#Test_scores

  def share_tooltip_modal(anchor, url, school_name)
    str = '<div class="sharing-modal">'
    SHARE_LINKS.each do | hash |
      if hash[:link_name] == 'Email'
        str += '<div class="sharing-row js-emailSharingLinks" data-link="'+hash[:link]+email_query_string(anchor, url, school_name)+'">'
      elsif hash[:link].present?
        str += '<div class="sharing-row js-sharingLinks" data-url="'+url+'" data-type="'+hash[:link_name]+'" data-anchor="'+anchor+'" data-link="'+hash[:link]+'">'
      else
        str += '<div class="sharing-row">'
      end

      str += '<div class="sharing-icon-box">'
      str += '<span class="'+hash[:icon]+'"></span>'
      str += '</div>'
      str += '<span class="sharing-row-text">'+hash[:link_name]+'</span>'
      str += '<div><input class="permalink" type="text" value="'+ url +'" /></div>' if hash[:link_name] == 'Permalink'
      str += '</div>'
    end
    str + '</div>'
  end

  def email_subject(anchor, school_name)
    '?subject=' + ("#{school_name} - #{anchor.gsub('_',' ')}")
  end

  def email_body(anchor, url, school_name)
    body = "&body=Check out the #{school_name} - #{anchor.gsub('_',' ')}%0D%0A"
    body << "#{url}/#{email_utm(url)}##{anchor}"
    URI.encode(body)
    body
  end

  def email_utm(url)
    email_utm = url =~ /\?/ ? '&' : '?'
    email_utm << "utm_source=profile%26utm_medium=email"
  end

  def email_query_string(anchor, url, school_name)
    email_subject(anchor, school_name) + email_body(anchor, url, school_name)
  end

end