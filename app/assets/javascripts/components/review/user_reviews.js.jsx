class UserReviews extends React.Component {
  constructor(props) {
    super(props);
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
  avatar: React.PropTypes.number
}
