class FiveStarRating extends React.Component {
  constructor(props) {
    super(props);
    this.handleStarResponseClick = this.handleStarResponseClick.bind(this);
  }

  handleStarResponseClick(value) {
    return () => this.props.onClick(value, this.props.question_id)
  }

  fiveStars(numberFilled) {
    var filled = [];
    for (var i=0; i < numberFilled; i++) {
      filled.push(<span className="icon-star filled-star" onClick={this.handleStarResponseClick(i+1)} key={i}></span>);
    }
    var empty = [];
    for (i=numberFilled; i < 5; i++) {
      empty.push(
        <span className="icon-star empty-star" onClick={this.handleStarResponseClick(i+1)} key={i}></span>);
    }
    return(
      <div className="five-star-rating__stars--med">
        <span className="five-stars">
          { filled }
          { empty }
        </span>
      </div>
    )
  }

  render() {
    return (
      <div className="five-star-rating">
        { this.fiveStars(this.props.value) }
      </div>
    )
  }
}
