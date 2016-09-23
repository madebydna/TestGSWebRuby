class TextArea extends React.Component {
  constructor(props) {
    super(props);
    this.handleTextBoxChange = this.handleTextBoxChange.bind(this);
  }

  handleTextBoxChange(event) {
    this.props.onTextValueChanged(event.target.value, this.props.question_id)
  }

  render() {
    return(
      <textarea className="js-comment" onChange={this.handleTextBoxChange}></textarea>
    );
  }
}
