class Questions extends React.Component {
  constructor(props) {
    super(props);
    this.renderQuestion = this.renderQuestion.bind(this);
  }

  renderQuestions() {
    return this.props.questions.map(this.renderQuestion);
  }

  layoutComponentForQuestion(question) {
    let responseKey = question.id.toString();
    let selectedValue;
    if (this.props.selectedResponses[responseKey]) {
      selectedValue = this.props.selectedResponses[responseKey].answerValue;
    }
    let component;
    if (question.layout == 'overall_stars') {
      component = (<FiveStarRating
        value = {selectedValue}
        responseValues = {question.response_values}
        responseLabels = {question.response_labels}
        question_id = {question.id}
        onClick = {this.props.responseSelected}
      />)
    } else {
      component = (<SelectBoxes
        value = {selectedValue}
        responseValues = {question.response_values}
        responseLabels = {question.response_labels}
        question_id = {question.id}
        onClick = {this.props.responseSelected}
      />)
    }
    return component;
  }

  shouldQuestionDisplayTextArea(question) {
    if (question.layout === 'overall_stars') {
      return false;
    } else {
      return true;
    }
  }

  renderFiveStarCommentQuestion(question) {
    let layoutComponent = (<TextArea
      question_id = {question.id}
      onTextValueChanged = {this.props.textValueChanged}
      errorMessage = { this.props.errorMessages[question.id] }
    />)
    return(<Question
      id = {question.id}
      subtext = { "Required" }
      questionCounter = {this.props.questions.length + 1}
      title = {question.title}
      layout = {layoutComponent}
      shouldDisplayTextArea = {false}
      errorMessage = { this.props.errorMessages[question.id] }
    />)
  }

  renderQuestion(question, index) {
    let responseKey = question.id.toString();
    let layoutComponent = this.layoutComponentForQuestion(question);
    let shouldDisplayTextArea =this.shouldQuestionDisplayTextArea(question);
    return(<Question
      response_values = {question.response_values}
      response_labels = {question.response_labels}
      id = {question.id}
      key = {question.id}
      questionCounter = {index + 1}
      title = {question.title}
      value = {this.props.selectedResponses[responseKey]}
      layout = {layoutComponent}
      shouldDisplayTextArea = {shouldDisplayTextArea}
      textValueChanged = {this.props.textValueChanged}
      errorMessage = { this.props.errorMessages[responseKey] }
    />)
  }

  render() {
    return (
      <div className="review-questions">
        { this.renderQuestions() }
        { this.renderFiveStarCommentQuestion(this.props.questions[0]) }
      </div>
    )
  }
}
