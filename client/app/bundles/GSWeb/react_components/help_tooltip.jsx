import React from 'react';
import ollie from 'school_profiles/owl_tutorial_prompt.svg';
import { t } from 'util/i18n';
import OpenableCloseable from './openable_closeable';
import { links } from '../components/links';
import { analyticsEvent } from "util/page_analytics";

const renderHelpCircle = (numArr) => (
  numArr.map(num => <div className={`help-circle circle-rating--${num}`}>{num}</div>)
)

const content = close => (
  <div className="rating-help-container">
    <span
      className="icon-close btn-close"
      onClick={close}
      onKeyPress={close}
      role="button"
    />
    <h4>{t("search_help.help")}</h4>
    <p>{t("search_help.greatschool_rating")}</p>
    <div className="ratings-scale-container">
      <div className="block-container">
        <div className="rating-scale">{renderHelpCircle([1, 2, 3, 4])}</div>
        <p
        dangerouslySetInnerHTML={{__html: t("search_help.rating.below_average_html")}}
          className="word-scale"
        />
      </div>
      <div className="block-container">
        <div className="rating-scale">{renderHelpCircle([5, 6])}</div>
        <p className="word-scale" dangerouslySetInnerHTML={{ __html: t("search_help.rating.average_html") }}/>
      </div>
      <div className="block-container">
        <div className="rating-scale">{renderHelpCircle([7, 8, 9, 10])}</div>
        <p className="word-scale" dangerouslySetInnerHTML={{ __html: t("search_help.rating.above_average_html") }} />
      </div>
    </div>
    <hr />
    <div>
      <div className="circle-nr circle-rating--gray unrated" />
      {t("search_help.currently_rated")} <br /> <br />
      {t("search_help.currently_rated_info")}
    </div>
    <hr />
    <p>
      <span className="bold">{t("search_help.search_suggestions")}</span>
      <br />
    </p>
    <a href={links.zendesk} target="_blank">
      {t("search_help.send_feedback")}
    </a>
  </div>
);

const HelpTooltip = () => (
  <OpenableCloseable>
    {(isOpen, { open, close, toggle }) => {
      const closeModal = (e) => (
        e.target.classList.contains("help-overlay") ? close() : null
      )
      const handleToggle = (e) => {
        analyticsEvent('search', 'help', `main-help`)
        toggle();
      }
      return (<React.Fragment>
        <img
          src={ollie}
          className="owly_size"
          alt="owl_icon"
          onClick={handleToggle}
        />
        <div onClick={closeModal} className= {isOpen ? "help-overlay" : null}>
          {isOpen ? content(close) : null}
        </div>
      </React.Fragment>)
    }}
  </OpenableCloseable>
);

export default HelpTooltip;
