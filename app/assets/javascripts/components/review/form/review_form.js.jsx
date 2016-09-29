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
      errorMessages: {},
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
    if (selectedResponses[questionId]) {
      selectedResponses[questionId].answerValue = value;
    } else {
      selectedResponses[questionId] = {answerValue: value};
    }
    this.setState(
      {
        selectedResponses: selectedResponses
      }
    );
  }

  textValueChanged(value, id) {
    let selectedResponses = this.state.selectedResponses;
    let questionId = id.toString();
    if (selectedResponses[questionId]) {
      selectedResponses[questionId].comment = value;
    } else {
      selectedResponses[questionId] = {comment: value};
    }
    this.setState(
      {
        selectedResponses: selectedResponses
      }
    );
  }

  cancelForm() {
    this.hideQuestions();
  }

  buildFormData() {
    let responses = this.state.selectedResponses;
    let formData = {
      state: this.props.state,
      school_id: this.props.schoolId,
      reviews_params: this.buildReviewsData()
    };
    return formData;
  }

  buildReviewsData() {
    let selectedResponses = this.state.selectedResponses;
    let reviewsData = [];
    _.forOwn(selectedResponses, function (reviewResponse, questionId) {
      reviewsData.push(
        {
          review_question_id: questionId,
          comment: reviewResponse.comment,
          answer_value: reviewResponse.answerValue
        }
        );
    });
    return JSON.stringify(reviewsData);
  }

  submitForm() {
    let data = this.buildFormData();
    $.ajax({
      url: "/gsr/reviews",
      method: 'POST',
      data: data,
      dataType: 'json',
      success: function (xhr, status) {
        this.handleSuccessfulSubmit(xhr);
      }.bind(this),
      error: function (xhr, status, err) {
        this.handleFailSubmit(xhr, status, err);
      }.bind(this)
    });
  }

  handleFailSubmit(xhr, status, err) {
    let formErrors = JSON.parse(xhr.responseText);
    let reviewsErrors = formErrors.reviews[0];
    if (reviewsErrors) {
      this.updateReviewFormErrors(reviewsErrors);
    }
  }

  handleSuccessfulSubmit(xhr) {
    let reviews = xhr;
    let reviewsErrors = this.reviewsErrors(reviews);
    if (reviewsErrors) {
      this.updateReviewFormErrors(reviewsErrors);
    } else {
      this.setState( { displayAllQuestions: false } );
    }
  }

  updateReviewFormErrors(reviewsErrors) {
    this.setState ( { errorMessages: reviewsErrors });
  }

  reviewsErrors(reviews) {
    let reviewsErrors = {};
    _.forOwn(reviews, function (review, questionId) {
      if (review.error_messages) {
        reviewsErrors[questionId] = review.error_messages[0];
      }
    });
    if (Object.keys(reviewsErrors).length > 0) {
      return reviewsErrors;
    } else {
      return false;
    }
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
      errorMessages = {this.state.errorMessages}
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
