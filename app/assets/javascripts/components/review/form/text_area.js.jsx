class TextArea extends React.Component {
  constructor(props) {
    super(props);
    this.handleTextBoxChange = this.handleTextBoxChange.bind(this);
  }

  handleTextBoxChange(event) {
    this.props.onTextValueChanged(event.target.value, this.props.question_id)
  }

  render() {
    let textareaClass;
    if (this.props.errorMessage) {
      textareaClass = "review-error";
    }
    return(
      <div className={textareaClass}>
        <textarea  onChange={this.handleTextBoxChange}></textarea>
      </div>
    );
  }
}
