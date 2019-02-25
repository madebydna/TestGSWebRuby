import React from 'react';
import PropTypes from 'prop-types';
import { t } from 'util/i18n';
import DataModule from "react_components/data_module";
import { XS, size as viewportSize } from 'util/viewport';
import { scrollToElement } from 'util/scrolling';
import InfoBox from 'react_components/school_profiles/info_box';
import { analyticsEvent } from "util/page_analytics";

class Academics extends React.Component {
  static propTypes = {
    academics: PropTypes.object,
    locality: PropTypes.object
  };

  static defaultProps = {
    academics: {}
  }

  constructor(props) {
    super(props);
  }

  render() {
    let { title, anchor, subtitle, info_text, icon_classes, sources, share_content, rating, data, analytics_id, showTabs, faq, feedback } = this.props.academics;
    return (
      <DataModule
        title={title}
        anchor={anchor}
        subtitle={subtitle}
        info_text={info_text}
        icon_classes={icon_classes}
        sources={sources}
        share_content={share_content}
        rating={rating}
        data={data}
        analytics_id={analytics_id}
        showTabs={showTabs}
        faq={faq}
        feedback={feedback}
        suppressIfEmpty={true}
        footer={
          <div data-ga-click-label={title}>
            <InfoBox content={sources} element_type="sources">{t('See notes')}</InfoBox>
            <div className="module_feedback">
              <a href={`https://s.qualaroo.com/45194/a8cbf43f-a102-48f9-b4c8-4e032b2563ec?state=${this.props.locality.stateShort}&districtId=${this.props.locality.district_id}`} className="anchor-button" target="_blank" rel="nofollow">
                {t('search_help.send_feedback')}
              </a>
            </div>
          </div>
        }
      />
    )
  }
}

export default Academics;