module SharingTooltipModal
  extend ActiveSupport::Concern

  included do
    include Rails.application.routes.url_helpers
    include UrlHelper
  end

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

  def share_tooltip_modal(anchor, school)
    url = school_url(school)
    school_name = school.name
    str = '<div class="sharing-modal">'
    SHARE_LINKS.each do | hash |
      if hash[:link_name] == 'Email'
        str += '<div class="sharing-row js-emailSharingLinks js-slTracking" data-link="'+hash[:link]+email_query_string(anchor, url, school_name)+'">'
      elsif hash[:link_name] == 'Facebook'
        str += facebook_link(url, anchor, school_name, hash[:link])
      elsif hash[:link_name] == 'Twitter'
        str += twitter_link(url, anchor, school_name, hash[:link])
      else
        str += '<div class="sharing-row">'
      end

      str += '<div class="sharing-icon-box">'
      str += '<span class="'+hash[:icon]+'"></span>'
      str += '</div>'
      str += '<span class="sharing-row-text">'+hash[:link_name]+'</span>'
      str += perma_link(url, anchor, hash[:link]) if hash[:link_name] == 'Permalink'
      str += '</div>'
    end
    str + '</div>'
  end

  def perma_link(url, module_name, link)
    new_params = {}
    new_params[:utm_source] = 'profile'
    new_params[:utm_medium] = 'Permalink'
    new_params[:lang] = current_language.to_s if current_language.to_s != 'en'
    url_new = add_query_params_to_url(url, false, new_params)
    url_new = set_anchor(url_new, module_name)
    '<div><input class="permalink js-permaLink js-slTracking" type="text" value="'+ url_new +'" /></div>'
  end

  def facebook_link(url, module_name, school_name, link)
    content_text = school_name + ' - ' + module_name.gsub('_', ' ')
    new_params = {}
    new_params[:utm_source] = 'profile'
    new_params[:utm_medium] = 'Facebook'
    new_params[:t] = content_text
    new_params[:lang] = current_language.to_s if current_language != 'en'
    url_new = add_query_params_to_url(url, false, new_params)
    url_new = set_anchor(url_new, module_name)
    '<div class="sharing-row js-sharingLinks js-slTracking" data-url="'+url_new+'" data-type="Facebook" data-module="'+module_name+'" data-link="'+link+'">'
  end

  def twitter_link(url, module_name, school_name, link)
    content_text = school_name + ' - ' + module_name.gsub('_', ' ')
    new_params = {}
    new_params[:utm_source] = 'profile'
    new_params[:utm_medium] = 'Twitter'
    new_params[:via] = 'GreatSchools'
    new_params[:text] = content_text
    new_params[:lang] = current_language.to_s if current_language.to_s != 'en'
    url_new = add_query_params_to_url(url, false, new_params)
    url_new = set_anchor(url_new, module_name)
    '<div class="sharing-row js-sharingLinks js-slTracking" data-url="'+url_new+'" data-type="Twitter" data-module="'+module_name+'" data-link="'+link+'">'
  end

  def current_language
    @_current_language ||= I18n.locale
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