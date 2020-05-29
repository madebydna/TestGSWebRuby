import React from 'react';
import PropTypes from 'prop-types';
import DataModule from 'react_components/data_module';
import InfoBox from 'react_components/school_profiles/info_box';
import GiveUsFeedback from 'react_components/school_profiles/give_us_feedback';
import ShortenText from '../shorten_text';
import ComputerScreen from '../icons/computer_screen';
import ForwardArrowBlue from 'icons/forward_arrow_blue.png';
import { t } from '../../util/i18n';

export default class DistanceLearning extends React.Component {
  constructor(props) {
    super(props);
  }

  renderQualarooDistrictLink() {
    let url = this.props.distance_learning.qualaroo_module_link;
    let state = this.props.locality.stateShort;
    let districtId = this.props.locality.district_id;

    return `${url}?state=${state}&districtId=${districtId}`;
  }

  renderOverview() {
    let label = t('distance_learning.see_more');
    return (
      <div>
        <div>
          <div className="module-overview-header">
            {t('distance_learning.district_overview') }:
          </div>
        </div>
        <p><ShortenText text={this.props.distance_learning.overview} length={200} label={label} renderDownArrow={true} /></p>
      </div>
    );
  }

  renderIcon() {
    return (
      <div className="module-icon">
        <ComputerScreen />
      </div>
    );
  }

  renderFooter() {
    let content = t('distance_learning.district_website_cta_html', { parameters: { url: this.props.distance_learning.url } });

    return (
      <div data-ga-click-label={"Distance Learning"}>
        <div className="module-footer-left">
          <InfoBox content={this.props.distance_learning.sources} element_type="sources" pageType={this.props.pageType}>{ t('See notes') }</InfoBox>
          <div>
            <span dangerouslySetInnerHTML={{ __html: content }} />&nbsp;
            <img className="forward-arrow" src={ForwardArrowBlue} />
          </div>
        </div>
        <div className="module-footer-right">
          {this.renderQualarooDistrictLink() && <GiveUsFeedback content={this.renderQualarooDistrictLink()} />}
        </div>
      </div>
    )
  }

  render() {
    return (
      <DataModule
        title="Distance Learning"
        anchor={this.props.distance_learning.anchor}
        analytics_id={this.props.distance_learning.analytics_id}
        subtitle=""
        moduleOverview={this.renderOverview()}
        info_text={this.props.distance_learning.tooltip}
        icon_classes={this.renderIcon()}
        share_content={this.props.distance_learning.share_content}
        data={this.props.distance_learning.data_values}
        faq={this.props.distance_learning.faq}
        no_data_summary={this.props.distance_learning.no_data_summary}
        footer={this.renderFooter()}
      />
    )
  }
}