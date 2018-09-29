import React from 'react';
import PropTypes from 'prop-types';
import TopicalReview from './topical_review';
import ShortenText from '../shorten_text';
import ReportReview from './report_review.jsx';
import { t } from '../../util/i18n';

export default class UserReviews extends React.Component {

  static propTypes = {
    five_star_review: PropTypes.object,
    topical_reviews: PropTypes.array,
    most_recent_date: PropTypes.string,
    user_type_label: PropTypes.string,
    avatar: PropTypes.number,
    review_reported_callback: PropTypes.func,
    current_user_reported_reviews: PropTypes.array,
    school_name: PropTypes.string
  };

  constructor(props) {
    super(props);
    this.state = {reportReviewOpen: false};
  }

  fiveStars(numberFilled) {
    var filled = [];
    for (var i=0; i < numberFilled; i++) {
      filled.push(<span className="icon-star filled-star" key={i}></span>);
    }
    var empty = [];
    for (i=numberFilled; i < 5; i++) {
      empty.push(<span className="icon-star empty-star" key={i}></span>);
    }
    return(
      <span className="five-stars">
        { filled }
        { empty }
      </span>
    )
  }

  topicalReviews() {
    if(this.props.topical_reviews) {
      return this.props.topical_reviews.map(function (review) {
        var userAlreadyReported = this.props.current_user_reported_reviews.indexOf(review.id) >= 0;
        return (<TopicalReview review={review} key={review.id}
                               reportedCallback={this.handleReviewReported.bind(this, review.id)}
                               userAlreadyReported={userAlreadyReported}
        />)
      }, this);
    }
  }

  fiveStarReview() {
    var review = this.props.five_star_review;
    if(review !== undefined) {
      return(
        <div className="five-star-review" key={review.id}>
          <div className="header">
            { t(review.topic_label) }
          </div>
          <div className="answer">
            { this.fiveStars(review.answer) }
          </div>
          <div className="comment">
            <ShortenText text={review.comment} length={200} key={review.text} />
          </div>
        </div>
      );
    }
  }

  reportReviewMobileLabel(review) {
    if (this.props.current_user_reported_reviews.indexOf(review.id) >= 0) {
      return (
          <span className="visible-xs-inline pls">{t('Reported')}</span>
      )
    }
  }

  buttonBar(review) {
    if (review !== undefined) {
      var alreadyReported = this.props.current_user_reported_reviews.indexOf(review.id) >= 0;
      const desktopLabel = alreadyReported ? t('Review Reported') : t('Report Review');
      return (
        <div className="review-button-bar">
          <span className={'button' + (alreadyReported ? ' reported' : '')} onClick={this.handleReportReviewClick.bind(this, review.id)}>
            <span className="icon-flag"></span>
            <span className="hidden-xs-inline pls">{desktopLabel}</span>
            { this.reportReviewMobileLabel(review) }
          </span>
        </div>
      )
    }
  }

  reportFiveStarReview() {
    var review = this.props.five_star_review;
    if (review !== undefined) {
      return (
          <ReportReview open={this.state.reportReviewOpen}
                        review={review}
                        cancelCallback={ this.handleCancelReportReviewClick.bind(this) }
                        reportedCallback={ this.handleReviewReported.bind(this, review.id) }
          />
      );
    }
  }

  handleReportReviewClick(reviewId, event) {
    if (!(this.props.current_user_reported_reviews.indexOf(reviewId) >= 0)) {
      this.setState({reportReviewOpen: !this.state.reportReviewOpen});
    }
    event.preventDefault();
  }

  handleCancelReportReviewClick() {
    this.setState({reportReviewOpen: false});
  }

  handleReviewReported(reviewId) {
    this.handleCancelReportReviewClick();
    this.props.review_reported_callback(reviewId);
  }

  userTypeAndDate() {
    let userType = this.props.user_type_label;
    let userTypeSentence = t('Submitted ');
    if (userType) {
      userTypeSentence += t('by a ') + userType.toLowerCase() + ' \u00B7 ';
    }
    return (
        <div className="type-and-date">
          { this.props.pageType === "Community" && `Review for ${this.props.school_name}` } <br/>
          { userTypeSentence }
          { this.props.most_recent_date }
        </div>
    )
  }

  render() {
    return (
      <div className="user-reviews-container">
        <div className="row">
          <div className="col-xs-12 col-sm-2 user-info-column">
            <div className={"avatar icon-avatar-" + this.props.avatar}></div>
            <div className="user-type">{ this.props.user_type_label }</div>
          </div>
          <div className="col-xs-12 col-sm-10 review-list-column">
            { this.fiveStarReview() }
            { this.topicalReviews() }
            { this.userTypeAndDate() }
            { this.buttonBar(this.props.five_star_review) }
            { this.reportFiveStarReview() }
          </div>
        </div>
      </div>
    );
  }
}
