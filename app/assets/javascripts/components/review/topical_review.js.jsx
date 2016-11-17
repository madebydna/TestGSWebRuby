class TopicalReview extends React.Component {
  constructor(props) {
    super(props);
    this.state = {reportReviewOpen: false}
  }

  topicalReviewReportLink() {
    var isReported = !!this.props.userAlreadyReported;
    if (isReported) {
      return (
          <div className="reported">Review Reported</div>
      )
    } else {
      return (
          <a href="#" onClick={this.handleReportReviewClick.bind(this)}>Report</a>
      )
    }
  }

  handleReportReviewClick(event) {
    event.preventDefault();
    this.setState({reportReviewOpen: !this.state.reportReviewOpen});
  }

  handleCancelClick() {
    this.setState({reportReviewOpen: false});
  }

  handleReviewReported() {
    // TODO: Actually report the review to the server, error handling, etc.
    // For now, assume it was successful. Close the form and update the parent
    this.setState({reportReviewOpen: false});
    this.props.reportedCallback();
  }

  render() {
    const review = this.props.review;
    return(
        <div className="topical-review" key={review.id}>
          <div className="average-rating-column">
            <span className={"answer-icon " + review.answer }></span>
          </div>
          <div className="text-column">
            <div className="answer" dangerouslySetInnerHTML={{__html: review.answer_label}} />

            <div className="comment">
              <ShortenText text={review.comment} length={200} key={review.text} />
            </div>
            <div className="topical-review-button-bar">
            <div className="topical-review-report">
              { this.topicalReviewReportLink(review.id) }
            </div>
            </div>
            <ReportReview open={this.state.reportReviewOpen}
                          review={review}
                          cancelCallback={ this.handleCancelClick.bind(this) }
                          reportedCallback={ this.handleReviewReported.bind(this, review.id) }
            />
          </div>
        </div>
    )
  }
}

ReportReview.propTypes = {
  review: React.PropTypes.object.isRequired,
  reportedCallback: React.PropTypes.func,
  userAlreadyReported: React.PropTypes.bool,
};
