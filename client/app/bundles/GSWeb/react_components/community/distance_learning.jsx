import React from 'react';
import PropTypes from 'prop-types';
import DataModule from 'react_components/data_module';
import InfoBox from 'react_components/school_profiles/info_box';
import GiveUsFeedback from 'react_components/school_profiles/give_us_feedback';
import ParentTip from 'react_components/school_profiles/parent_tip';
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
    return (
      <ParentTip>
        <span dangerouslySetInnerHTML={{__html: t('distance_learning.parent_tip')}}/>
      </ParentTip>
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
          {this.props.distance_learning.url && <div>
            <span dangerouslySetInnerHTML={{ __html: content }} />&nbsp;
            <img className="forward-arrow" src={ForwardArrowBlue} />
          </div>}
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
        title={t('distance_learning.title')}
        anchor={this.props.distance_learning.anchor}
        analytics_id={this.props.distance_learning.analytics_id}
        subtitle={t('distance_learning.subtitle')}
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