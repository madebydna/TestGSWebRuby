class ReviewForm extends React.Component {
  constructor(props) {
    super(props);
    this.fiveStarQuestionSelect = this.fiveStarQuestionSelect.bind(this);
    this.responseSelected = this.responseSelected.bind(this);
    this.cancelForm = this.cancelForm.bind(this);
    this.submitForm = this.submitForm.bind(this);
    this.textValueChanged = this.textValueChanged.bind(this);
    this.state = {
      displayCTA: true,
      displayAllQuestion: false,
      selectedResponses: {},
      selectedFiveStarResponse: null
    };
  }

  renderFiveStarQuestionCTA() {
    let fiveStarQuestion = this.props.questions[0];
    return(<FiveStarQuestionCTA
      response_values = {fiveStarQuestion.response_values}
      response_labels = {fiveStarQuestion.response_labels}
      id = {fiveStarQuestion.id}
      title = {fiveStarQuestion.title}
      fiveStarQuestionSelect = {this.fiveStarQuestionSelect }
    />)
  }

  showQuestions() {
    this.setState(
      {
        displayCTA: false,
        displayAllQuestions: true
      }
    );
  }

  hideQuestions() {
    this.setState(
      {
        displayCTA: true,
        displayAllQuestions: false
      }
    );
  }

  fiveStarQuestionSelect(value, id) {
    this.showQuestions();
    this.responseSelected(value, id);
  }

  responseSelected(value, id) {
    let selectedResponses = this.state.selectedResponses;
    let questionId = id.toString()
    selectedResponses[questionId] = value;
    this.setState(
      {
        selectedResponses: selectedResponses
      }
    );
  }

  textValueChanged(value, id) {
    let selectedResponses = this.state.selectedResponses;
    let questionId = 'comment'+ id.toString();
    selectedResponses[questionId] = value;
    this.setState(
      {
        selectedResponses: selectedResponses
      }
    );
  }

  cancelForm() {
    this.hideQuestions();
  }

  submitForm() {

    this.setState( { displayAllQuestions: false } );
  }

  renderFormActions() {
    return(
      <div className="form-actions clearfix">
        <button className="submit" onClick={this.submitForm}>Submit</button>
        <button className="cancel" onClick={this.cancelForm}>Cancel</button>
      </div>
    );
  }

  renderQuestions() {
    return(<Questions
      questions = {this.props.questions}
      selectedResponses = {this.state.selectedResponses}
      responseSelected = {this.responseSelected}
      textValueChanged = {this.textValueChanged}
     />);
  }

  render() {
    return (
      <div className="review-form">
        { this.state.displayCTA ? this.renderFiveStarQuestionCTA() : null }
        { this.state.displayAllQuestions ? this.renderQuestions() : null }
        { this.state.displayAllQuestions ? this.renderFormActions() : null }
      </div>
    );
  }
}
