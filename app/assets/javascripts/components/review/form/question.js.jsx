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

  renderErrorMessage() {
    return(
      <div className="error-message">
        { this.props.errorMessage }
      </div>
    );
  }

  renderTextArea() {
    let textClass;
    if (this.props.errorMessage) {
      textClass = "review-error";
      }
    return(
      <div className={textClass}>
        <textarea onBlur={this.handleTextBlur}
          autoFocus={true}
          onChange={this.handleTextBoxChange}>
        </textarea>
      </div>
      );
  }

  handleTextBoxChange(event) {
    this.setState({textValue: event.target.value})
    this.props.textValueChanged(event.target.value, this.props.id)
  }

  renderTellUsLink() {
    return(
      <div className="tell-us-link" onClick={this.displayTextArea}>
        <span className="icon-pencil"></span>
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

  renderSubtext() {
    return (
      <div className="subtext">
        { this.props.subtext }
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
            { this.props.subtext ? this.renderSubtext() : null }
          </div>
          { this.renderLayout() }
          <ReactCSSTransitionGroup
            transitionName="textarea"
            transitionEnterTimeout={400}
            transitionLeaveTimeout={400}>
            { (this.props.value && this.props.shouldDisplayTextArea) ? this.renderTellUsWhy() : null }
          </ReactCSSTransitionGroup>
          { this.props.errorMessage ? this.renderErrorMessage() : null }
        </div>
      </div>
    )
  }
}
