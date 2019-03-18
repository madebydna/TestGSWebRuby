import React from 'react';
import PropTypes from 'prop-types';
import { stringify } from 'query-string';
import parseUrl from 'url-parse';
import { assign } from 'lodash';
import Tooltip from 'react_components/school_profiles/tooltip';
import { t, localeQueryParams } from '../../util/i18n';
import { renderToStaticMarkup } from 'react-dom/server';

window.parseUrl = parseUrl;
// const foo = <div class="tipso_content">
// <div class="sharing-modal">
// </div>;

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

const URIencode = () => {};

const addParamsToUrl = (fullUrl, newParams) => {
  const url = parseUrl(fullUrl);
  url.set('query', assign(url.query || {}, newParams));
  return url.toString();
};

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

const utmParams = (source, medium) => ({
  utm_source: source,
  utm_medium: medium,
  ...localeQueryParams()
});

// const facebookLink = (url, moduleName, schoolName, link) => {
//   const content_text = `${schoolName  } - ${  moduleName.gsub('_', ' ')}`;
//   const queryParams = utmParams('profile', 'Facebook');
//   const new_url = `${addParamsToUrl(url, queryParams)  }#${  moduleName}`;
// };

const mailtoUrl = (url, moduleName, schoolName) => {
  const lineBreak = '\r\n';
  const readableModuleName = moduleName.replace(/_/g, ' ');
  const urlWithUtmParams = `${addParamsToUrl(
    url,
    utmParams('Profile', 'Email')
  )}`;
  const mailto = stringify({
    subject: `${schoolName} - ${readableModuleName}`,
    body: `Check out the ${schoolName} - ${readableModuleName}${lineBreak}${urlWithUtmParams}`
  });
  return `mailto:?${mailto}`;
};

const sharingRow = ({ url, type, title, moduleName }) => {
  const icons = {
    email: 'mail',
    facebook: 'facebook',
    permalink: 'link',
    twitter: 'twitter'
  };
  const className = type === 'Email' ? 'emailSharingLinks' : 'sharingLinks';
  const iconName = icons[type.toLowerCase()];

  return (
    <div
      className={`sharing-row js-${className} js-slTracking`}
      data-type={type}
      data-module={moduleName}
      data-link={url}
    >
      <div className="sharing-icon-box">
        <span className={`icon-${iconName}`} />
      </div>
      <span className="sharing-row-text">{type}</span>
    </div>
  );
};

const defaultShareContent = (url, moduleName = '', schoolName) => {
  const readableModuleName = moduleName.replace(/_/g, ' ');

  return (
    <div className="sharing-modal">
      {sharingRow({
        url: mailtoUrl(url, moduleName, schoolName),
        type: 'Email',
        title: `${schoolName} - ${readableModuleName}`,
        moduleName
      })}

      <div
        className="sharing-row js-sharingLinks js-slTracking"
        data-url={`${addParamsToUrl(
          url,
          assign(utmParams('Profile', 'Facebook'), {
            t: 'Alameda High School - College readiness'
          })
        )}`}
        data-type="Facebook"
        data-module="College_readiness"
        data-link="https://www.facebook.com/sharer/sharer.php?u="
      >
        <div className="sharing-icon-box">
          <span className="icon-facebook" />
        </div>
        <span className="sharing-row-text">Facebook</span>
      </div>

      <div
        className="sharing-row js-sharingLinks js-slTracking"
        data-url={`${addParamsToUrl(
          url,
          assign(utmParams('Profile', 'Twitter'), {
            via: 'GreatSchools',
            text: 'Alameda High School - College readiness'
          })
        )}`}
        data-type="Twitter"
        data-module="College_readiness"
        data-link="https://twitter.com/share?url="
      >
        <div className="sharing-icon-box">
          <span className="icon-twitter" />
        </div>
        <span className="sharing-row-text">Twitter</span>
      </div>

      <div className="sharing-row">
        <div className="sharing-icon-box">
          <span className="icon-link" />
        </div>
        <span className="sharing-row-text">Permalink</span>
        <div>
          <input
            className="permalink js-permaLink js-slTracking"
            type="text"
            value={`${addParamsToUrl(url, utmParams('Profile', 'Permalink'))}`}
          />
          <span className="acknowledgement">Copied to clipboard</span>
        </div>
      </div>
    </div>
  );
};

const SharingModal = ({ content }) => (
  <Tooltip
    content={
      content ||
      renderToStaticMarkup(
        defaultShareContent(
          'https://www.greatschools.org/california/alameda/1-Alameda-High-School#College_readiness',
          'College_readiness',
          'Alameda High School'
        )
      )
    }
  >
    <span>
      <span className="icon-share" />&nbsp;
      {t('Share')}
    </span>
  </Tooltip>
);

SharingModal.propTypes = {
  content: PropTypes.string.isRequired
};

export default SharingModal;
