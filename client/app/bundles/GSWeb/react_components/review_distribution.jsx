import React from 'react';
import PropTypes from 'prop-types';
import { t } from '../util/i18n';

export default class ReviewDistribution extends React.Component {

  static propTypes = {
    distribution: PropTypes.object.isRequired
  };

  constructor(props) {
    super(props);
  }

  renderBar(answer, scale, answerCount, totalReviews) {
    var percentageOfTotal = (answerCount / totalReviews) * 40;
    if (percentageOfTotal < 1) {
      percentageOfTotal = 0.5;
    }
    var iconClassName = "answer-icon topic-icon " + answer.toLowerCase().replace(' ', '-');
    var barColorClassName = "bar rating_scale-5_" + scale;
    var style={width: percentageOfTotal + "%"};
    return (
        <div className="rating-bar-viz">
          <span className={iconClassName}/>
          <span className="title">{t(answer)}</span>
          <span className={barColorClassName} style={style}/>
          <span className="answer-count">{answerCount}</span>
        </div>
    );
  }

  render() {
    var topicMap = this.props.distribution.dist;
    var question = this.props.distribution.question;
    var stronglyAgree = topicMap['Strongly agree'] || 0;
    var agree = topicMap['Agree'] || 0;
    var neutral = topicMap['Neutral'] || 0;
    var disagree = topicMap['Disagree'] || 0;
    var stronglyDisagree = topicMap['Strongly disagree'] || 0;
    var max = Math.max(stronglyAgree, agree, neutral, disagree, stronglyDisagree);
    max = max + 1; // never fill a bar up all the way
    return (
        <div className="topical-review review-distribution">
          <h4 dangerouslySetInnerHTML={ {__html: question} }/>
          { this.renderBar('Strongly agree', 5, stronglyAgree, max) }
          { this.renderBar('Agree', 4, agree, max) }
          { this.renderBar('Neutral', 3, neutral, max) }
          { this.renderBar('Disagree', 2, disagree, max) }
          { this.renderBar('Strongly disagree', 1, stronglyDisagree, max) }
        </div>
    );
  }
}
