var ReactCSSTransitionGroup = React.addons.CSSTransitionGroup;

class Question extends React.Component {
  constructor(props) {
    super(props);
    this.displayTextArea = this.displayTextArea.bind(this);
    this.handleTextBoxChange = this.handleTextBoxChange.bind(this);
    this.handleTextBlur = this.handleTextBlur.bind(this);
    this.state = {
      shouldDisplayTextArea: false,
      shouldDisplayTellUsLink: true,
      textValue: '',
      textFocus: true
    };
  }

  renderLayout() {
    return(this.props.layout);
  }

  displayTextArea() {
    this.setState(
      {
        shouldDisplayTellUsLink: false,
        shouldDisplayTextArea: true
      });
  }

  handleTextBlur() {
    if (this.state.textValue === '') {
      this.setState(
        {
          shouldDisplayTextArea: false,
          shouldDisplayTellUsLink: true
        })
    }
  }

  renderTextArea() {
    return(
      <textarea className="js-comment" onBlur={this.handleTextBlur} autoFocus={true} onChange={this.handleTextBoxChange}></textarea>
    );
  }

  handleTextBoxChange(event) {
    this.setState({textValue: event.target.value})
    this.props.textValueChanged(event.target.value, this.props.id)
  }

  renderTellUsLink() {
    let pencilColor = {
      color: '#999999'
    };
    return(
      <div className="tell-us-link" onClick={this.displayTextArea}>
        <span className="icon-pencil"  style={pencilColor}></span>
        Tell us why&hellip;
       </div>
    );
  }

  renderTellUsWhy() {
    return(
      <div className="tell-us-why">
        <ReactCSSTransitionGroup
          transitionName="tell-us-link"
          transitionEnterTimeout={600}
          transitionLeaveTimeout={100}>
          { this.state.shouldDisplayTellUsLink ? this.renderTellUsLink() : false }
        </ReactCSSTransitionGroup>
        <div className="tell-us-text">
          <ReactCSSTransitionGroup
            transitionName="textarea"
            transitionEnterTimeout={800}
            transitionLeaveTimeout={100}>
            { this.state.shouldDisplayTextArea ? this.renderTextArea() : null }
          </ReactCSSTransitionGroup>
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
          { this.renderLayout() }
          <ReactCSSTransitionGroup
            transitionName="textarea"
            transitionEnterTimeout={400}
            transitionLeaveTimeout={400}>
          { (this.props.value && this.props.shouldDisplayTextArea) ? this.renderTellUsWhy() : null }
        </ReactCSSTransitionGroup>
        </div>
      </div>
    )
  }
}
