class FiveStarQuestionCTA extends React.Component {
  constructor(props) {
    super(props);
    this.handleStarResponseClick = this.handleStarResponseClick.bind(this);
    this.renderStarResponse = this.renderStarResponse.bind(this);
  }

  renderStarResponses() {
    return this.props.response_labels.map(this.renderStarResponse);
  }

  handleStarResponseClick(value) {
    return () => this.props.fiveStarQuestionSelect(value);
  }

  // consistify the grabbing of the selected value 
  renderStarResponse(label, index) {
    return(
      <div key={index} className="five-star-question__response-container">
        <div onClick={this.handleStarResponseClick(index+1)}>
          <div className="icon-star five-star-question__star"></div>
          <div className="five-star-question__response-label">{label}</div>
        </div>
      </div>
    );
  }

  render() {
    return (
      <div  className="five-star-question">
        <div className="row">
          <div className="col-xs-12 col-sm-2">
            <div className="five-star-question__avatar icon-avatar-1"></div>
            <div className="five-star-question__user-type">You</div>
          </div>
          <div className="col-xs-12 col-sm-10 five-star-question__container">
            <div className="five-star-question__title">
              { this.props.title }
            </div>
            { this.renderStarResponses() }
          </div>
        </div>
      </div>
    )
  }
}
