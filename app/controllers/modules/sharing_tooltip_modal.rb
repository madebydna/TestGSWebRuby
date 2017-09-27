module SharingTooltipModal
  SHARE_LINKS = [
      {icon: 'icon-mail', link: 'Email'},
      {icon: 'icon-facebook', link: 'Facebook'},
      {icon: 'icon-twitter', link: 'Twitter'},
      {icon: 'icon-link', link: 'Permalink'},
      {icon: 'icon-share', link: 'SMS'}
  ]

  def share_tooltip_modal
    str = '<div class="sharing-modal">'
    SHARE_LINKS.each do | hash |
      str += '<div class="sharing-row">'
      str += '<div class="sharing-icon-box">'
      str += '<span class="'+hash[:icon]+'"></span>'
      str += '</div>'
      str += '<span class="sharing-row-text">'+hash[:link]+'</span>'
      str += '<div><input class="permalink" type="text" value="link goes here" /></div>' if hash[:link] == 'Permalink'
      str += '</div>'
    end
    str + '</div>'
  end

end