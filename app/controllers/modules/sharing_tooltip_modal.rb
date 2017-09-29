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
      {icon: 'icon-link', link_name: 'Permalink'}
  ]

  def share_tooltip_modal(anchor, school)
    url = school_url(school)
    school_name = school.name
    str = '<div class="sharing-modal">'
    SHARE_LINKS.each do | hash |
      if hash[:link_name] == 'Email'
        str += email_link(url, anchor, school_name, hash[:link])
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
      str += perma_link(url, anchor) if hash[:link_name] == 'Permalink'
      str += '</div>'
    end
    str + '</div>'
  end

  def perma_link(url, module_name)
    new_params = {}
    new_params[:utm_source] = 'profile'
    new_params[:utm_medium] = 'Permalink'
    new_params[:lang] = current_language.to_s if current_language.to_s != 'en'
    url_new = add_query_params_to_url(url, false, new_params)
    url_new = set_anchor(url_new, module_name)
    acknowledgement = I18n.t('controllers.school_profile_controller.Copied to clipboard')
    '<div><input class="permalink js-permaLink js-slTracking" type="text" value="'+ url_new +'" /><span class="acknowledgement">' + acknowledgement + '</span></div>'
  end

  def facebook_link(url, module_name, school_name, link)
    content_text = school_name + ' - ' + module_name.gsub('_', ' ')
    new_params = {}
    new_params[:utm_source] = 'profile'
    new_params[:utm_medium] = 'Facebook'
    new_params[:lang] = current_language.to_s if current_language.to_s != 'en'
    url_new = add_query_params_to_url(url, false, new_params)
    url_new = set_anchor(url_new, module_name)
    facebook_str = '&t=' + content_text
    '<div class="sharing-row js-sharingLinks js-slTracking" data-url="'+url_new+'" data-siteparams="' + facebook_str + '" data-type="Facebook" data-module="'+module_name+'" data-link="'+link+'">'
  end

  def twitter_link(url, module_name, school_name, link)
    content_text = school_name + ' - ' + module_name.gsub('_', ' ')
    new_params = {}
    new_params[:utm_source] = 'profile'
    new_params[:utm_medium] = 'Twitter'
    new_params[:lang] = current_language.to_s if current_language.to_s != 'en'
    url_new = add_query_params_to_url(url, false, new_params)
    url_new = set_anchor(url_new, module_name)
    twitter_str = '&via=GreatSchools&text='+content_text
    '<div class="sharing-row js-sharingLinks js-slTracking" data-url="'+url_new+'" data-siteparams="' + twitter_str + '" data-type="Twitter" data-module="'+module_name+'" data-link="'+link+'">'
  end

  def current_language
    @_current_language ||= I18n.locale
  end

  def email_link(url, module_name, school_name, link)
    content_text = "Check out the #{school_name} - #{module_name.gsub('_',' ')}%0D%0A"
    new_params = {}
    new_params[:utm_source] = 'profile'
    new_params[:utm_medium] = 'Email'
    new_params[:subject] = "#{school_name} - #{module_name.gsub('_',' ')}"
    new_params[:body] = content_text
    new_params[:lang] = current_language.to_s if current_language.to_s != 'en'
    url_new = add_query_params_to_url(url, false, new_params)
    url_new = set_anchor(url_new, module_name)
    '<div class="sharing-row js-emailSharingLinks js-slTracking" data-url="'+url_new+'" data-type="Email" data-module="'+module_name+'" data-link="'+link+email_query_string(module_name, url, school_name)+'">'
  end

  def email_subject(anchor, school_name)
    '?subject=' + ("#{school_name} - #{anchor.gsub('_',' ')}")
  end

  def email_body(anchor, url, school_name)
    body = "body=Check out the #{school_name} - #{anchor.gsub('_',' ')}%0D%0A"
    body << "#{url}/#{email_utm(url)}##{anchor}"
    URI.encode(body)
    body
  end

  def email_utm(url)
    email_utm = url =~ /\?/ ? '&' : '?'
    email_utm << "utm_source=profile%26utm_medium=email"
  end

  def email_query_string(anchor, url, school_name)
    [email_subject(anchor, school_name),email_body(anchor, url, school_name)].join('&')
  end

end