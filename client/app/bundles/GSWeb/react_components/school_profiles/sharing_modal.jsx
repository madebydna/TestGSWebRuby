import React from 'react';
import PropTypes from 'prop-types';
import { parse, stringify } from 'query-string';
import parseUrl from 'url-parse';
import { assign } from 'lodash';
import { renderToStaticMarkup } from 'react-dom/server';
import Tooltip from 'react_components/school_profiles/tooltip';
import { t, localeQueryParams, capitalize } from '../../util/i18n';

/**
 * Given a url returns a new URL by merging/overwriting
 * query params in the source URL with the given new params
 * 
 * @param {string} fullUrl 
 * @param {Object} newParams 
 */
const addParamsToUrl = (fullUrl, newParams) => {
  const url = parseUrl(fullUrl);
  url.set('query', assign(parse(url.query) || {}, newParams));
  return url.toString();
};

/**
 * Returns an obj with props that can be formed into a query string
 * for tracking how/where the user came from when navigating to a URL
 * 
 * @param {string} source utm_source
 * @param {string} medium utm_medium
 */
const utmParams = (source, medium) => ({
  utm_source: source,
  utm_medium: medium,
  ...localeQueryParams()
});

/**
 * ? is moduleName really needed/used? 
 * 
 * @param {Object} obj
 * @param {string} obj.url Full "share" URL for whichever service
 * @param {string} obj.type (email,facebook,permalink,twitter) Type of Sharing service, used to determine icon
 * @param {string} obj.moduleName Name of the module where the sharing behavior is being added
 */
const sharingRow = ({ url, type, moduleName }) => {
  const icons = {
    email: 'mail',
    facebook: 'facebook',
    permalink: 'link',
    twitter: 'twitter'
  };
  const className = type === 'Email' ? 'emailSharingLinks' : 'sharingLinks';
  const iconName = icons[type.toLowerCase()];
  const dataAttrs = {
    'data-type': type,
    'data-module': moduleName,
    'data-link': url
  }
  return (
    <div
      className={`sharing-row js-${className} js-slTracking`}
      {...dataAttrs}
    >
      <div className="sharing-icon-box">
        <span className={`icon-${iconName}`} />
      </div>
      <span className="sharing-row-text">{t(type)}</span>
    </div>
  );
};

/**
 * Generates a mailto url. When user clicks link containing this URL, email client
 * should open with subject and message body populated. Message body should contain
 * a URL for the page we're driving the recipient to.
 * 
 * @param {string} url A GreatSchools URL to place into email message body
 * @param {string} subject
 * @param {string} text Beginning of email body
 */
const mailtoUrl = (url, title, text) => {
  const lineBreak = '\r\n';
  const mailto = stringify({
    subject: title,
    body: `${text}${lineBreak}${url}`
  });
  return `mailto:?${mailto}`;
};

/**
 * @param {string} url A GreatSchools URL to place into a Facebook share URL
 * @param {string} text Default text for end user write into their post
 */
const facebookUrl = (url, text) => parseUrl('https://www.facebook.com/sharer/sharer.php').set('query', stringify({
  u: url,
  t: text
})).toString();

/**
 * @param {string} url A GreatSchools URL to place into a Facebook share URL
 * @param {string} text Default text for end user write into their post
 */
const twitterUrl = (url, text) => parseUrl('https://twitter.com/intent/tweet').set('query', stringify({
  url,
  via: 'GreatSchools',
  text
})).toString();

/**
 * @param {Object} obj
 * @param {string} obj.url A GreatSchools URL to place various share URLs
 * @param {string} obj.title Some common text that will be populated into share popups or email
 * @param {string} obj.pageName Used for the utm_source. The page that the user event originated from
 * @param {string} obj.moduleName Not required. If page has multiple modules that have Share functionality, the name of the module
 */
export const defaultShareContent = ({url, title, pageName, moduleName}) => {
  return (
  <div className="sharing-modal">
    {sharingRow({
      url: mailtoUrl(
        `${addParamsToUrl(url, utmParams(pageName, 'Email'))}`,
        title,
        `Check out the ${title}`
      ),
      type: 'Email',
      title,
      moduleName
    })}

    {sharingRow({
      url: facebookUrl(
        `${addParamsToUrl(url, utmParams(pageName, 'Facebook'))}`,
        title
      ),
      type: 'Facebook',
      title,
      moduleName
    })}

    {sharingRow({
      url: twitterUrl(
        `${addParamsToUrl(url, utmParams(pageName, 'Twitter'))}`,
        title
      ),
      type: 'Twitter',
      title,
      moduleName
    })}

    <div className="sharing-row">
      <div className="sharing-icon-box">
        <span className="icon-link" />
      </div>
      <span className="sharing-row-text">{t('Permalink')}</span>
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
  )
};


const SharingModal = ({ content, url, title, pageName, moduleName = undefined, className}) => (
  <Tooltip
    content={
      content ||
      renderToStaticMarkup(
        defaultShareContent({ url, title, pageName, moduleName })
      )
    }

    className={className}
  >
    <span>
      <span className="icon-share" />&nbsp;
      {t('Share')}
    </span>
  </Tooltip>
);

SharingModal.defaultProps = {
  url: undefined,
  title: undefined,
  pageName: undefined,
  className: '',
  moduleName: undefined
};

SharingModal.propTypes = {
  content: PropTypes.string,
  url: PropTypes.string,
  title: PropTypes.string,
  pageName: PropTypes.string,
  moduleName: PropTypes.string,
  className: PropTypes.string
};

export default SharingModal;
