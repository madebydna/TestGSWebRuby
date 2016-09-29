class ReviewsList extends React.Component {
  constructor(props) {
    super(props);
    var currentUserReportedMap = {};
    // TODO: This needs to be hooked up somewhere. Maybe from props?
    this.state = {currentUserReportedMap: currentUserReportedMap};
    this.reviewReportedCallback = this.reviewReportedCallback.bind(this);
  }

  initialReviews() {
    return this.props.reviews.slice(0,3).map(this.renderOneUsersReviews.bind(this));
  }

  drawerReviews() {
    return this.props.reviews.slice(3).map(this.renderOneUsersReviews.bind(this));
  }

  reviewReportedCallback(reviewId) {
    if (reviewId) {
      var newAttr = {};
      newAttr[reviewId] = true;
      this.setState({currentUserReportedMap: Object.assign({}, this.state.currentUserReportedMap, newAttr)});
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
      current_user_has_reported={!!this.state.currentUserReportedMap[userReviews.five_star_review.id]}
      review_reported_callback={this.reviewReportedCallback}
    />)
  }

  render() {
    return (
      <div className="review-list">
        <div>{this.initialReviews()}</div>
        <Drawer content={this.drawerReviews()} />
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
    avatar: React.PropTypes.number
  }))
};
