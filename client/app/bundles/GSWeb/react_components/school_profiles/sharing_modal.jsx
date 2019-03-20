import React from 'react';
import PropTypes from 'prop-types';
import { stringify, parseUrl } from 'query-string';
import { assign } from 'lodash';
import { t, localeQueryParams } from '../../util/i18n';

/*
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
    url = StructuredMarkup.ensure_https(school_url(school))
    school_name = school.name
    SHARE_LINKS.each do | hash |
      if hash[:link_name] == 'Email'
        // str += email_link(url, anchor, school_name, hash[:link])
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

  def email_utm(url)
    email_utm = url =~ /\?/ ? '&' : '?'
    email_utm << "utm_source=profile%26utm_medium=email"
  end

end
*/

const current_language = 'en';

const URIencode = () => {}

const addParamsToUrl = (url, newParams) => {
  const { urlWithoutQs, queryParams } = parseUrl(url);
  return `${urlWithoutQs}?${stringify(assign(queryParams, newParams))}`
}

// def facebook_link(url, module_name, school_name, link)
// content_text = school_name + ' - ' + module_name.gsub('_', ' ')
// new_params = {}
// new_params[:utm_source] = 'profile'
// new_params[:utm_medium] = 'Facebook'
// new_params[:lang] = current_language.to_s if current_language.to_s != 'en'
// url_new = add_query_params_to_url(url, false, new_params)
// url_new = set_anchor(url_new, module_name)
// facebook_str = '&t=' + content_text
// '<div class="sharing-row js-sharingLinks js-slTracking" data-url="'+url_new+'" data-siteparams="' + facebook_str + '" data-type="Facebook" data-module="'+module_name+'" data-link="'+link+'">'
// end

// const facebookLink = (url, moduleName, schoolName, link) => {
//   const content_text = schoolName + ' - ' + moduleName.gsub('_', ' ')
//   const queryParams = {
//     utm_source: 'profile',
//     utm_medium: 'Facebook',
//     ...localeQueryParams()
//   }
//   const new_url = addParamsToUrl(url, queryParams) + '#' + moduleName

// }



// const emailUtm = (url) => {
//   const qs = stringify({
//     utm_source: 'profile',
//     utm_medium: 'email'
//   });
//   const delim = (!url.match(/\?/)) ? '?' : '&';
//   return `${url}${delim}${qs}`;
// }

// const emailQueryString = (anchor, url, schoolName) => {
//   const params = {
//     subject: (`${schoolName} - ${anchor.replace(/_/g,' ')}`),
//     body: `Check out the ${schoolName} - ${anchor.gsub('_',' ')}%0D%0A${url}/${emailUtm(url)}#${anchor}`
//   }
//   return stringify(params);
// }

// const emailUrl = (url, moduleName, schoolName, link) => {
//   const newParams = {
//     utm_source: 'profile',
//     utm_medium: 'Email',
//     subject: `${schoolName} - ${moduleName.gsub('_',' ')}`,
//     body: "Check out the #{school_name} - #{module_name.gsub('_',' ')}%0D%0A",
//     ...localeQueryParams()
//   };
//   return `${addParamsToUrl(url, newParams)}#${moduleName}`
// }

// const defaultShareContent = <div className="sharing-modal">
//   <div class="sharing-row js-emailSharingLinks js-slTracking"/>
//   data-url={emailUrl()} data-type="Email" data-module={module_name} data-link={link + email_query_string(module_name, url, school_name) }>
// </div>;

const SharingModal = ({ content }) => (
  <a
    data-remodal-target="modal_info_box"
    data-content-type="info_box"
    data-content-html={content}
    className="share-link gs-tipso"
    data-tipso-width="318"
    data-tipso-position="left"
    href="javascript:void(0)">
      <span className="icon-share"></span>&nbsp;
      {t('Share')}
    </a>
);

SharingModal.propTypes = {
  content: PropTypes.string.isRequired
}

export default SharingModal;
