var ReviewsList = React.createClass({
  initialReviews: function() {
    return this.props.reviews.slice(0,3).map(review => {
      return(<UserReviews
        fiveStarReview = {review.fiveStarReview}
        fiveStarReviewRating = {review.fiveStarReviewRating}
        topicalReviews = {review.topicalReviews}
        mostRecentDate = {review.mostRecentDate}
        userTypeLabel = {review.userTypeLabel}
        avatar = {review.avatar}
      />)
    });
  },

  drawerReviews: function() {
    return this.props.reviews.slice(3).map(review => {
      return(<UserReviews
        fiveStarReview = {review.fiveStarReview}
        fiveStarReviewRating = {review.fiveStarReviewRating}
        topicalReviews = {review.topicalReviews}
        mostRecentDate = {review.mostRecentDate}
        userTypeLabel = {review.userTypeLabel}
        avatar = {review.avatar}
      />)
    });
  },

  render: function() {
    return(
      <div>
        <div>{this.initialReviews()}</div>
        <Drawer content={this.drawerReviews()} />
      </div>
    )
  }
})
