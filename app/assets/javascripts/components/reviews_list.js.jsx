class ReviewsList extends React.Component {
  constructor(props) {
    super(props);
  }

  initialReviews() {
    return this.props.reviews.slice(0,3).map(this.renderOneUsersReviews);
  }

  drawerReviews() {
    return this.props.reviews.slice(3).map(this.renderOneUsersReviews);
  }

  renderOneUsersReviews(userReviews) {
    return(<UserReviews
      five_star_review = {userReviews.five_star_review}
      topical_reviews = {userReviews.topical_reviews}
      most_recent_date = {userReviews.most_recent_date}
      user_type_label = {userReviews.user_type_label}
      avatar = {userReviews.avatar}
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
