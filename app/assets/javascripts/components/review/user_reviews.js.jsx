class UserReviews extends React.Component {
  constructor(props) {
    super(props);
    this.state = {reportReviewOpen: false};
    this.handleReportReviewClick = this.handleReportReviewClick.bind(this);
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

  topicalReview(review) {
    return(
      <div className="topical-review" key={review.id}>
        <div className="average-rating-column">
          <span className={"answer-icon " + review.answer }></span>
        </div>
        <div className="text-column">
          <div className="answer">
            { review.answer_label }
          </div>
          <div className="comment">
            <ShortenText text={review.comment} length={200} key={review.text} />
          </div>
        </div>
      </div>
    )
  }

  topicalReviews() {
    if(this.props.topical_reviews) {
      return this.props.topical_reviews.map(this.topicalReview);
    }
  }

  fiveStarReview() {
    var review = this.props.five_star_review;
    if(review !== undefined) {
      return(
        <div className="five-star-review" key={review.id}>
          <div className="header">
            { review.topic_label }
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

  reportReviewMobileLabel() {
    if (this.props.current_user_has_reported) {
      return (
          <span className="visible-xs-inline pls">Reported</span>
      )
    }
  }

  buttonBar() {
    var alreadyReported = this.props.current_user_has_reported;
    const desktopLabel = alreadyReported ? 'Review Reported' : 'Report Review';
    return (
        <div className="review-button-bar">
          <span className={'button' + (alreadyReported ? ' reported' : '')} onClick={this.handleReportReviewClick}>
            <span className="icon-flag"></span>
            <span className="hidden-xs-inline pls">{desktopLabel}</span>
            { this.reportReviewMobileLabel() }
          </span>
        </div>
    )
  }

  handleReportReviewClick() {
    if (!this.props.current_user_has_reported) {
      this.setState({reportReviewOpen: !this.state.reportReviewOpen});
    }
  }

  handleCancelReportReviewClick() {
    this.setState({reportReviewOpen: false});
  }

  handleReviewReported(reviewId) {
    this.setState({reportReviewOpen: false});
    this.props.review_reported_callback(reviewId);
  }

  render() {
    var review = this.props.five_star_review;
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
            <div className="date">
              { this.props.most_recent_date}
            </div>
            { this.buttonBar() }
            <ReportReview open={this.state.reportReviewOpen} review={review}
                          cancelCallback={ this.handleCancelReportReviewClick.bind(this) }
                          reportedCallback={ this.handleReviewReported.bind(this) }
            />
          </div>
        </div>
      </div>
    );
  }
}

UserReviews.propTypes = {
  five_star_review: React.PropTypes.object,
  topical_reviews: React.PropTypes.array,
  most_recent_date: React.PropTypes.string,
  user_type_label: React.PropTypes.string,
  avatar: React.PropTypes.number,
  current_user_has_reported: React.PropTypes.bool,
  review_reported_callback: React.PropTypes.func,
};
