class NearbySchool extends React.Component {
  constructor(props) {
    super(props);
  }

  renderGSRating() {
    if(this.props.GSRating === undefined) {
      return null;
    }
    return (
      <div className={"circle-rating circle-rating--small circle-rating--" + this.props.GSRating}>
        {this.props.GSRating}<span className="rating-circle-small">/10</span>
      </div>
    );
  }

  fiveStars(numberFilled) {
    if (numberFilled === undefined) {
      return null;
    }

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

  renderRating() {
    if(this.props.GSRating !== undefined && this.props.GSRating != 'nr') {
      return (
        <div className="rating">
          {this.renderGSRating()}
          {this.fiveStars(this.props.averageRating)}
        </div>
      );
    } else {
      return (<div className="no-rating"></div>);
    }
  }

  distance() {
    if(this.props.distance === undefined) {
      return null;
    }
    return (Math.round(this.props.distance * 100) / 100) + " miles";
  }

  render() {
    return (
      <div className="nearby-school">
        {this.renderRating()}
        <div>
          <a>{this.props.schoolName}</a>
          <div className="school-info">
            <span>{this.props.schoolType}</span>
            <span>{this.props.gradeRange}</span>
            <span>{this.props.city}, {this.props.state}</span>
          </div>
          <div>{this.distance()}</div>
        </div>
      </div>
    )
  }
}

NearbySchool.propTypes = {
  GSRating: React.PropTypes.string,
  averageRating: React.PropTypes.number,
  schoolName: React.PropTypes.string,
  schoolType: React.PropTypes.string,
  gradeRange: React.PropTypes.string,
  city: React.PropTypes.string,
  state: React.PropTypes.string,
  distance: React.PropTypes.number
}
