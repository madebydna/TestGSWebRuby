import React from 'react';
import PropTypes from 'prop-types';
import ReviewDistribution from './review_distribution';
import ModalTooltip from './modal_tooltip';

export default class TopicalReviewSummary extends React.Component {
  static propTypes = {
    title: PropTypes.string.isRequired,
    topics: PropTypes.array.isRequired,
    distributions_by_topic: PropTypes.object.isRequired,
    summaries_by_topic: PropTypes.object.isRequired
  };

  renderItems() {
    return this.props.topics.map(topic => {
      const content = (
        <ReviewDistribution
          distribution={this.props.distributions_by_topic[topic]}
          className="topical_item"
        />
      );
      return (
        <ModalTooltip
          key={topic}
          content={content}
          gaLabel={`topical review summary -${topic}`}
        >
          <a className="topical_item">
            <span
              className={`answer-icon topic-icon ${this.props.summaries_by_topic[
                topic
              ].average
                .toLowerCase()
                .replace(/\s/g, '-')}`}
            />
            <span className="topic-details">
              {topic} &nbsp;({this.props.summaries_by_topic[topic].count})
            </span>
          </a>
        </ModalTooltip>
      );
    });
  }

  render() {
    return (
      <div>
        <a className="anchor-mobile-offset" name="Topical_Review_Summary" />
        <div className="topical-review">
          <div className="topical-review-summary">
            <div className="row">
              <div className="col-xs-12 col-lg-3">
                <div className="topical-title">{this.props.title}</div>
              </div>
              <div className="col-xs-12 col-lg-9 topical_items">
                {this.renderItems()}
              </div>
            </div>
          </div>
        </div>
      </div>
    );
  }
}
