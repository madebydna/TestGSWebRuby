import React from 'react';
import PropTypes from 'prop-types';
import DataModule from 'react_components/data_module';
import ComputerScreen from '../icons/computer_screen';

export default class DistanceLearning extends DataModule {
  constructor(props) {
    super(props);
    this.renderIcon = this.renderIcon.bind(this);
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
        subtitle={this.props.distance_learning.overview}
        info_text={this.props.distance_learning.tooltip}
        icon_classes={this.renderIcon()}
        sources={this.props.distance_learning.sources}
        share_content={this.props.distance_learning.share_content}
        data={this.props.distance_learning.data_values}
        faq={this.props.distance_learning.faq}
        no_data_summary={this.props.distance_learning.no_data_summary}
        qualaroo_module_link={this.props.distance_learning.qualaroo_module_link}
      />
    )
  }
}