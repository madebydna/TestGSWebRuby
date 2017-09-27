module SharingTooltipModal
  SHARE_LINKS = [
      {icon: 'icon-mail', link: 'Email'},
      {icon: 'icon-facebook', link: 'Facebook'},
      {icon: 'icon-twitter', link: 'Twitter'},
      {icon: 'icon-link', link: 'Permalink'},
      {icon: 'icon-share', link: 'SMS'}
  ]

  FACEBOOK_BASE_SHARE_URL = 'https://www.facebook.com/sharer/sharer.php?u='
  TWITTER_BASE_SHARE_URL = 'https://twitter.com/share?url='
  URLENCODED_URL = ''
  TITLE = ''
  TWITTER_HANDLE = ''
  TEXT = ''

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

  def facebook_link
    ( '<a href="https://www.facebook.com/sharer/sharer.php?u=' + URLENCODED_URL + '&t=' + TITLE + '"
    onclick="javascript:window.open(this.href, \'\', \'menubar=no,toolbar=no,resizable=yes,scrollbars=yes,height=300,width=600\');return false;"
    target="_blank" title="Share on Facebook">
    </a>')
  end

  def twiiter_link
    ( '<a href="https://twitter.com/share?url=' + URLENCODED_URL + '&via=' + TWITTER_HANDLE + '&text=' + TEXT + '"
    onclick="javascript:window.open(this.href, \'\', \'menubar=no,toolbar=no,resizable=yes,scrollbars=yes,height=300,width=600\');return false;"
    target="_blank" title="Share on Twitter">
    </a>')
end

end