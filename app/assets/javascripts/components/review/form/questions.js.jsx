class Questions extends React.Component {
  constructor(props) {
    super(props);
    this.renderQuestion = this.renderQuestion.bind(this);
  }

  renderQuestions() {
    let topicalQuestions = this.props.questions.slice(1, this.props.questions.length+1)
    return topicalQuestions.map(this.renderQuestion);
  }

  //consolidate render five question into one
  renderFiveStarQuestion() {
    let question = this.props.questions[0];
    return(<FiveStarQuestion
      response_values = {question.response_values}
      response_labels = {question.response_labels}
      id = {question.id}
      title = {question.title}
      responseSelected = {this.props.responseSelected}
      value = { this.props.selectedResponses["1"] }
    />)
  }

  renderQuestion(question, index) {
    let responseKey = question.id.toString();
    return(<Question
      response_values = {question.response_values}
      response_labels = {question.response_labels}
      id = {question.id}
      questionCounter = {index +2}
      title = {question.title}
      value = { this.props.selectedResponses[responseKey] }
      responseSelected = {this.props.responseSelected}
    />)
  }

  render() {
    return (
      <div className="review-questions">
        { this.renderFiveStarQuestion() }
        { this.renderQuestions() }
      </div>
    )
  }
}
