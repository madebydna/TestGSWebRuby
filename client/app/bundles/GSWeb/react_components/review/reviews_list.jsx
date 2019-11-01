import React from 'react';
import PropTypes from 'prop-types';
import UserReviews from './user_reviews';
import { t } from 'util/i18n';
import { getQueryParam, updateUrlParameter } from 'components/header/query_param_utils';

export default class ReviewsList extends React.Component {
  static propTypes = {
    reviews: PropTypes.arrayOf(PropTypes.shape({
      five_star_review: PropTypes.object,
      topical_reviews: PropTypes.array,
      most_recent_date: PropTypes.string,
      user_type_label: PropTypes.string,
      avatar: PropTypes.number,
      reviewSubmitMessage: PropTypes.object
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
    let schoolPath;
    if (userReviews.school_path){
      schoolPath = userReviews.school_path;
      if (getQueryParam('lang') === 'es'){
        userReviews.school_path = updateUrlParameter(schoolPath,'lang','es')
      }
    }
    
    return(<UserReviews
      key = {userReviews.id}
      five_star_review = {userReviews.five_star_review}
      topical_reviews = {userReviews.topical_reviews}
      most_recent_date = {userReviews.most_recent_date}
      user_type_label = {userReviews.user_type_label}
      avatar = {userReviews.avatar}
      current_user_reported_reviews={this.state.currentUserReportedReviews}
      review_reported_callback={this.reviewReportedCallback}
      school_name = {userReviews.school_name}
      school_path = {userReviews.school_path}
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

