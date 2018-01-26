import React, { PropTypes } from 'react';
import UserReviews from './user_reviews';
import { t } from 'util/i18n';

export default class ReviewsList extends React.Component {

  static propTypes = {
    reviews: React.PropTypes.arrayOf(React.PropTypes.shape({
      five_star_review: React.PropTypes.object,
      topical_reviews: React.PropTypes.array,
      most_recent_date: React.PropTypes.string,
      user_type_label: React.PropTypes.string,
      avatar: React.PropTypes.number,
      reviewSubmitMessage: React.PropTypes.object
    }))
  };

  constructor(props) {
    super(props);
    let currentUserReportedReviews = [];

    // TODO: This needs to be hooked up somewhere. Maybe from props?
    this.state = {
      currentUserReportedReviews: currentUserReportedReviews
    };
    this.reviewReportedCallback = this.reviewReportedCallback.bind(this);
    this.renderReviewSubmitMessage = this.renderReviewSubmitMessage.bind(this);
  }


  renderReviewSubmitMessage() {
    if ( this.props.reviewSubmitMessage.message ) {
      let reviewMessageClass = "submit-review-message";
      if (this.props.reviewSubmitMessage.active ) {
       reviewMessageClass += " active";
      }
      return(
        <div className={reviewMessageClass}>
          { this.props.reviewSubmitMessage.message }
        </div>
      );
     }
  }

  displayReviews() {
    return this.props.reviews.slice(this.props.offset, this.props.limit)
      .map(this.renderOneUsersReviews.bind(this));
  }


  reviewReportedCallback(reviewId) {
    if (reviewId) {
      var reportedReviews = this.state.currentUserReportedReviews.slice();
      reportedReviews.push(reviewId);
      this.setState({currentUserReportedReviews: reportedReviews});
    }
  }

  renderOneUsersReviews(userReviews) {
    return(<UserReviews
      key = {userReviews.id}
      five_star_review = {userReviews.five_star_review}
      topical_reviews = {userReviews.topical_reviews}
      most_recent_date = {userReviews.most_recent_date}
      user_type_label = {userReviews.user_type_label}
      avatar = {userReviews.avatar}
      current_user_reported_reviews={this.state.currentUserReportedReviews}
      review_reported_callback={this.reviewReportedCallback}
    />)
  }

  render() {
    return (
      <div className="review-list">
        <div>{this.renderReviewSubmitMessage()}</div>
        <div>{this.displayReviews()}</div>

      </div>
    )
  }
}

