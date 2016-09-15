var UserReviews = React.createClass({
  fiveStars: function(numberFilled) {
    var filled = [];
    for (var i=0; i < numberFilled; i++) {
      filled.push(<span className="icon-star filled-star"></span>);
    }
    var empty = [];
    for (i=numberFilled; i < 5; i++) {
      empty.push(<span className="icon-star empty-star"></span>);
    }
    return(
      <span className="five-stars">
        { filled }
        { empty }
      </span>
    )
  },

  topicalReview: function(review) {
    return(
      <div className="topical-review">
        <div className="average-rating-column">
          <span className={"answer-icon " + review.answer }></span>
        </div>
        <div className="text-column">
          <div className="answer">
            { review.answerLabel }
          </div>
          <div className="comment">
            { review.comment }
          </div>
        </div>
      </div>
    )
  },

  topicalReviews: function() {
    return this.props.topicalReviews.map(function(review) {
      return this.topicalReview(review);
    }.bind(this));
  },

  fiveStarReview: function() {
    var review = this.props.fiveStarReview;
    if (review === undefined) {
      return "";
    }
    return(
      <div className="five-star-review">
        <div className="header">
          { review.topicLabel }
        </div>
        <div className="answer">
          { this.fiveStars(this.props.fiveStarReviewRating) }
        </div>
        <div className="comment">
          { review.comment }
        </div>
      </div>
    );
  },

  render: function() {
    return (
      <div className="user-reviews-container">
        <div className="row">
          <div className="col-xs-12 col-sm-2 user-info-column">
            <div className={"avatar icon-avatar-" + this.props.avatar}></div>
            <div className="user-type">{ this.props.userTypeLabel }</div>
          </div>
          <div className="col-xs-12 col-sm-10 review-list-column">
            { this.fiveStarReview() }
            { this.topicalReviews() }
            <div className="date">
              { this.props.mostRecentDate }
            </div>
          </div>
        </div>
      </div>
    );
  }
});
