class FiveStarQuestion extends React.Component {
  constructor(props) {
    super(props);
  }

  renderFiveStarRating(){
    return(<FiveStarRating
      value = {this.props.value}
      question_id = {this.props.id}
      onClick = {this.props.responseSelected}
    />)
  }

  render() {
    return (
      <div className="review-question clearfix">
        <div>
          <div className="review-counter"><span>{ this.props.id }</span></div>
        </div>
        <div>
          <div>
            { this.props.title }
          </div>
          <div className="five-star-rating">
            { this.renderFiveStarRating() }
          </div>
        </div>
      </div>
    )
  }
}
