import React, { PropTypes } from 'react';
import UserReviews from './user_reviews';
import { scrollToElement } from 'util/scrolling';
import { t } from 'util/i18n';
import { size as viewportSize } from 'util/viewport';

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
    this.REVIEW_CHUNK_SIZE = 5;
    let currentUserReportedReviews = [];

    // TODO: This needs to be hooked up somewhere. Maybe from props?
    this.state = {
      currentUserReportedReviews: currentUserReportedReviews,
      offset: 0,
      limit: this.startingLimit()
    };
    this.reviewReportedCallback = this.reviewReportedCallback.bind(this);
    this.renderReviewSubmitMessage = this.renderReviewSubmitMessage.bind(this);
    this.handleClick = this.handleClick.bind(this);
    this.handleCloseAllClick = this.handleCloseAllClick.bind(this);
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
    return this.props.reviews.slice(this.state.offset, this.state.limit)
      .map(this.renderOneUsersReviews.bind(this));
  }

  //returns a boolean
  isLastPage(){
    return this.props.reviews.length <= this.state.limit;
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

  startingLimit() {
    let limit = this.REVIEW_CHUNK_SIZE;
    if(viewportSize() == 'xs') {
      limit = 1;
    }

    if(limit > this.props.reviews.length) nextLimit = this.props.reviews.length;
    return limit;
  }

  nextLimit() {
    let limit = this.state.limit + this.REVIEW_CHUNK_SIZE;
    if(limit > this.props.reviews.length) limit = this.props.reviews.length;
    return limit;
  }

  handleClick() {
    this.setState({limit: this.nextLimit()});
  }

  handleCloseAllClick() {
    this.setState({limit: this.startingLimit()});
    scrollToElement('.review-summary');
  }

  showMoreButton(){
    if(!this.isLastPage()) {
      return (<div className="show-more__button" onClick={this.handleClick}>
        {t('Show more')}
      </div>);
    }
  }

  closeAllButton(){
    if(this.state.limit > this.startingLimit()) {
      return (<div className="tac ptm"><a onClick={this.handleCloseAllClick}>
        {t('Close all')}
      </a></div>);
    }
  }

  render() {
    return (
      <div className="review-list">
        <div>{this.renderReviewSubmitMessage()}</div>
        <div>{this.displayReviews()}</div>
        {this.showMoreButton()}
        {this.closeAllButton()}
      </div>
    )
  }
}
