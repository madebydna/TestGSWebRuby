module SharingTooltipModal
  SHARE_LINKS = [
      {icon: 'icon-mail', link_name: 'Email', link: 'mailto:"derek@greatschools.org"'},
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

  def share_tooltip_modal(anchor, url)
    str = '<div class="sharing-modal">'
    SHARE_LINKS.each do | hash |
      if hash[:link_name] == 'Email'
        str += '<div class="sharing-row">'
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



end