class UserReviews extends React.Component {
  constructor(props) {
    super(props);
    var reportReviewState = {};
    var fiveStarReview = this.props.five_star_review;
    if (fiveStarReview) {
      reportReviewState[fiveStarReview.id] = {open: false};
    }
    if (this.props.topical_reviews) {
      for (var i=0; i < this.props.topical_reviews.length; i++) {
        var topicalReview = this.props.topical_reviews[i];
        reportReviewState[topicalReview.id] = {open: false}
      }
    }
    this.state = {reportReviewState: reportReviewState};
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

  topicalReviewReportLink(reviewId) {
    var isReported = this.props.current_user_reported_reviews.includes(reviewId);
    if (isReported) {
      return (
          <span className="reported">Review Reported</span>
      )
    } else {
      return (
          <a href="#" onClick={this.handleReportReviewClick.bind(this, reviewId)}>Report</a>
      )
    }
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
          <div className="topical-review-button-bar">
            <span className="topical-review-report">
              { this.topicalReviewReportLink(review.id) }
            </span>
          </div>
          <ReportReview open={this.state.reportReviewState[review.id].open}
                        cancelCallback={ this.handleCancelReportReviewClick.bind(this, review.id) }
                        reportedCallback={ this.handleReviewReported.bind(this, review.id) }
          />
        </div>
      </div>
    )
  }

  topicalReviews() {
    if(this.props.topical_reviews) {
      return this.props.topical_reviews.map(this.topicalReview.bind(this));
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

  reportReviewMobileLabel(review) {
    if (this.props.current_user_reported_reviews.includes(review.id)) {
      return (
          <span className="visible-xs-inline pls">Reported</span>
      )
    }
  }

  buttonBar(review) {
    if (review !== undefined) {
      var alreadyReported = this.props.current_user_reported_reviews.includes(review.id);
      const desktopLabel = alreadyReported ? 'Review Reported' : 'Report Review';
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
          <ReportReview open={this.state.reportReviewState[review.id].open}
                        cancelCallback={ this.handleCancelReportReviewClick.bind(this, review.id) }
                        reportedCallback={ this.handleReviewReported.bind(this, review.id) }
          />
      );
    }
  }

  handleReportReviewClick(reviewId, event) {
    if (!this.props.current_user_reported_reviews.includes(reviewId)) {
      var newAttr = {};
      var currentState = this.state.reportReviewState[reviewId].open;
      newAttr[reviewId] = {open: !currentState};
      var newReportReviewState = Object.assign({}, this.state.reportReviewState, newAttr);
      this.setState({reportReviewState: newReportReviewState});
    }
    event.preventDefault();
  }

  handleCancelReportReviewClick(reviewId) {
    var newAttr = {};
    newAttr[reviewId] = {open: false};
    var newReportReviewState = Object.assign({}, this.state.reportReviewState, newAttr);
    this.setState({reportReviewState: newReportReviewState});
  }

  handleReviewReported(reviewId) {
    this.handleCancelReportReviewClick(reviewId);
    this.props.review_reported_callback(reviewId);
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
            <div className="date">
              { this.props.most_recent_date}
            </div>
            { this.buttonBar(this.props.five_star_review) }
            { this.reportFiveStarReview() }
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
  review_reported_callback: React.PropTypes.func,
  current_user_reported_reviews: React.PropTypes.array,
};
