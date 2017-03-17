import React, { PropTypes } from 'react';
import ReactCSSTransitionGroup from 'react-addons-css-transition-group';
import TextArea from './text_area';

export default class Question extends React.Component {

  static propTypes = {
    id: React.PropTypes.number.isRequired,
    questionCounter: React.PropTypes.number.isRequired,
    title: React.PropTypes.string.isRequired,
    subtext: React.PropTypes.string,
    layout: React.PropTypes.object.isRequired,
    shouldDisplayTextArea: React.PropTypes.bool,
    textValueChanged: React.PropTypes.func,
    errorMessage: React.PropTypes.string
  };

  constructor(props) {
    super(props);
    this.displayTextArea = this.displayTextArea.bind(this);
    this.handleTextBoxChange = this.handleTextBoxChange.bind(this);
    this.handleTextBlur = this.handleTextBlur.bind(this);
    this.handleTellUsWhyClick = this.handleTellUsWhyClick.bind(this);
    this.state = {
      shouldDisplayTextArea: (this.props.textValue && this.props.textValue != ''),
      shouldDisplayTellUsLink: !(this.props.textValue && this.props.textValue != ''),
      textFocus: false
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
    if (! this.props.textValue || this.props.textValue == '') {
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

  handleTellUsWhyClick() {
   this.setState({ textFocus: true})
   this.displayTextArea();
  }

  renderTextArea() {
    return(<TextArea
      questionId = {this.props.id}
      onTextValueChanged = {this.props.textValueChanged}
      handleTextBlur = { this.handleTextBlur }
      autoFocus = { this.state.textFocus }
      errorMessage = { this.props.errorMessage }
      textValue = { this.props.textValue }
    />);
    this.setState({ textFocus: false});
  }

  handleTextBoxChange(event) {
    this.setState({textValue: event.target.value})
    this.props.textValueChanged(event.target.value, this.props.id)
  }

  renderTellUsLink() {
    return(
      <div className="tell-us-link" onClick={this.handleTellUsWhyClick}>
        <span className="icon-pencil"></span>
        {GS.I18n.t('Tell us why')}&hellip;
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
            <div dangerouslySetInnerHTML={{__html: this.props.title }} />
            { this.props.subtext ? this.renderSubtext() : null }
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
