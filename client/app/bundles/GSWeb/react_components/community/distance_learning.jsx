import React from 'react';
import PropTypes from 'prop-types';
import DataModule from 'react_components/data_module';
import QuestionMarkTooltip from 'react_components/school_profiles/question_mark_tooltip';
import ShortenText from '../shorten_text';
import ComputerScreen from '../icons/computer_screen';
import { t } from '../../util/i18n';

export default class DistanceLearning extends DataModule {
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
    let content = t('distance_learning.district_overview_tooltip_html', { parameters: { url: this.props.distance_learning.url } });

    return (
      <div>
        <div>
          <div className="module-overview-header">
            {t('distance_learning.district_overview') }:&nbsp;
            <div className="tooltip"><QuestionMarkTooltip content={content} element_type='toptooltip' /></div>
          </div>
        </div>
        <p><ShortenText text={this.props.distance_learning.overview} length={200} /></p>
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
        sources={this.props.distance_learning.sources}
        share_content={this.props.distance_learning.share_content}
        data={this.props.distance_learning.data_values}
        faq={this.props.distance_learning.faq}
        no_data_summary={this.props.distance_learning.no_data_summary}
        qualaroo_module_link={this.renderQualarooDistrictLink()}
      />
    )
  }
}