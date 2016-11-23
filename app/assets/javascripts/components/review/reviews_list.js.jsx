class ReviewsList extends React.Component {

  constructor(props) {
    super(props);
    this.REVIEW_CHUNK_SIZE = 5;
    var currentUserReportedReviews = [];

    // TODO: This needs to be hooked up somewhere. Maybe from props?
    this.state = {
      currentUserReportedReviews: currentUserReportedReviews,
      pageNumber: 1
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
    return this.props.reviews.slice(0,this.countToDisplay()).map(this.renderOneUsersReviews.bind(this));
  }

  countToDisplay(){
    let last_to_show = this.currentMaxValue();
    if(this.lastPage()) last_to_show = this.props.reviews.length;
    return last_to_show;
  }

  currentMaxValue() {
    // this returns the slice position in an array, hence the -1
    return (this.REVIEW_CHUNK_SIZE * this.state.pageNumber - 1);
  }

  //returns a boolean
  lastPage(){
    // need to add a +1 to compensate for array shift
    let last_to_show = this.currentMaxValue() + 1;
    return (this.props.reviews.length <= last_to_show);
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

  handleClick() {
    // analyticsEvent(this.props.trackingCategory, this.props.trackingAction+' Less');
    let pageToOpen = this.state.pageNumber + 1;
    this.setState({pageNumber: pageToOpen});
  }

  handleCloseAllClick() {
    this.setState({pageNumber: 1});
    GS.reviewHelpers.scrollToReviewSummary();
  }

  showMoreButton(){
    if(!this.lastPage()) {
      return (<div className="show-more__button" onClick={this.handleClick}>
        Show more
      </div>);
    }
  }

  closeAllButton(){
    if(this.state.pageNumber != 1) {
      return (<div className="tac ptm"><a onClick={this.handleCloseAllClick}>
        Close All
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

ReviewsList.propTypes = {
  reviews: React.PropTypes.arrayOf(React.PropTypes.shape({
    five_star_review: React.PropTypes.object,
    topical_reviews: React.PropTypes.array,
    most_recent_date: React.PropTypes.string,
    user_type_label: React.PropTypes.string,
    avatar: React.PropTypes.number,
    reviewSubmitMessage: React.PropTypes.object
  }))
};
