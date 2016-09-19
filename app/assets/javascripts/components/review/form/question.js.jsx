class Question extends React.Component {
  constructor(props) {
    super(props);
    this.displayTextArea = this.displayTextArea.bind(this);
    this.state = {
      shouldDisplayTextArea: false
    }
  }

  renderSelectBoxes() {
    return(<SelectBoxes
      selectedValue = {this.props.value}
      question_id = {this.props.id}
      onClick = {this.props.responseSelected}
    />)
  }

  displayTextArea() {
    this.setState({shouldDisplayTextArea: true});
  }

  renderTextArea() {
    return (
    <textarea className="js-comment"></textarea>
    );
  }

  renderTellUsWhy() {
    let pencilColor = {
      color: '#999999'
    };
    return(
      <div className="tell-us-why">
        <div className="tell-us-link" onClick={this.displayTextArea}><span className="icon-pencil"  style={pencilColor}></span> Tell us why&hellip;</div>
        <div className="tell-us-text">
          { this.renderTextArea() }
        </div>
      </div>
    );
  }

  render() {
    return (
      <div className="review-question clearfix">
        <div>
          <div className="review-counter"><span>{ this.props.questionCounter }</span></div>
        </div>
        <div>
          <div>
            { this.props.title }
          </div>
          { this.renderSelectBoxes() }
          { this.props.value ? this.renderTellUsWhy() : null }
        </div>
      </div>
    )
  }
}
