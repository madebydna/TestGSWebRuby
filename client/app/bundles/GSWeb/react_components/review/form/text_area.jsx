import React, { PropTypes } from 'react';

export default class TextArea extends React.Component {

  static propTypes = {
    questionId: React.PropTypes.number.isRequired,
    onTextValueChanged: React.PropTypes.func.isRequired,
    handleTextBlur: React.PropTypes.func,
    errorMessage: React.PropTypes.string,
    textValue: React.PropTypes.string,
    autoFocus: React.PropTypes.bool,
    placeholder: React.PropTypes.string,
  }

  static defaultProps = {
    autoFocus: false
  }

  constructor(props) {
    super(props);
    this.handleTextBoxChange = this.handleTextBoxChange.bind(this);
  }

  handleTextBoxChange(event) {
    this.props.onTextValueChanged(event.target.value, this.props.questionId)
  }

  renderErrorMessage() {
    return(
      <div className="error-message">
        { this.props.errorMessage }
      </div>
    );
  }

  render() {
    let textareaClass;
    if (this.props.errorMessage) {
      textareaClass = "review-error";
    }
    return(
      <div className={textareaClass}>
        <textarea value={ this.props.textValue }
          onBlur = {this.props.handleTextBlur }
          autoFocus = { this.props.autoFocus }
          placeholder = { this.props.placeholder }
          onChange={this.handleTextBoxChange}/>
        { this.props.errorMessage ? this.renderErrorMessage() : null }
      </div>
    );
  }
}
