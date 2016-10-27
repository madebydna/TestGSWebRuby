class ReviewForm extends React.Component {
  constructor(props) {
    super(props);
    this.fiveStarQuestionSelect = this.fiveStarQuestionSelect.bind(this);
    this.responseSelected = this.responseSelected.bind(this);
    this.cancelForm = this.cancelForm.bind(this);
    this.submitForm = this.submitForm.bind(this);
    this.textValueChanged = this.textValueChanged.bind(this);
    this.sendReviewPost = this.sendReviewPost.bind(this);
    this.getSchoolUser = this.getSchoolUser.bind(this);
    this.updateReviewFormErrors = this.updateReviewFormErrors.bind(this);
    this.noSchoolUserExists = this.noSchoolUserExists.bind(this);
    this.handleSuccessfulSubmit = this.handleSuccessfulSubmit.bind(this);
    this.handleFailSubmit = this.handleFailSubmit.bind(this);
    this.promptUserWhenNavigatingAway = this.promptUserWhenNavigatingAway.bind(this);
    window.onbeforeunload = this.promptUserWhenNavigatingAway; 

    this.state = {
      displayCTA: true,
      displayAllQuestion: false,
      selectedResponses: {},
      errorMessages: {},
      selectedFiveStarResponse: null,
      unsavedChanges: false,
      disabled: false
    };
  }

  promptUserWhenNavigatingAway(e) {
    if (this.state.unsavedChanges) {
      e.returnValue = 'Your review has not been saved.';
      return e.returnValue;
    }
  }

  renderFiveStarQuestionCTA() {
    let fiveStarQuestion = this.props.questions[0];
    return(<FiveStarQuestionCTA
      responseValues = {fiveStarQuestion.response_values}
      responseLabels = {fiveStarQuestion.response_labels}
      id = {fiveStarQuestion.id}
      title = {fiveStarQuestion.title}
      fiveStarQuestionSelect = {this.fiveStarQuestionSelect}
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

  cloneSelectedResponses() {
    let selectedResponses = JSON.parse(JSON.stringify(this.state.selectedResponses));
    return selectedResponses;
  }

  responseSelected(value, id) {
    let selectedResponses = this.cloneSelectedResponses();
    let questionId = id.toString()
    if (selectedResponses[questionId]) {
      selectedResponses[questionId].answerValue = value;
    } else {
      selectedResponses[questionId] = {answerValue: value};
    }
    this.setState(
      {
        selectedResponses: selectedResponses,
        unsavedChanges: true
      }
    );
  }

  textValueChanged(value, id) {
    let selectedResponses = this.cloneSelectedResponses();
    let questionId = id.toString();
    if (selectedResponses[questionId]) {
      selectedResponses[questionId].comment = value;
    } else {
      selectedResponses[questionId] = {comment: value};
    }
    this.setState(
      {
        selectedResponses: selectedResponses,
        unsavedChanges: true
      }
    );
  }

  cancelForm() {
    this.setState({
      unsavedChanges: false
    });
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
    this.setState({disabled: true});
    if (GS.session.isSignedIn()) {
      GS.session.getCurrentSession().done(this.getSchoolUser).fail(this.sendReviewPost);
    } else {
      GS.modal.manager.showModal(GS.modal.SubmitReviewModal)
        .done(this.getSchoolUser)
        .fail(function() {
          this.updateReviewFormErrors({
            '1': 'Something went wrong logging you in'
          });
        }.bind(this));
    }
  }

  getSchoolUser(data) {
    let schoolUserModalOptions =  { state: this.props.state, schoolId: this.props.schoolId.toString() };
    let schoolUsers = data.user.school_users;
    if(this.noSchoolUserExists(schoolUsers)) {
      GS.modal.manager.showModal( GS.modal.SchoolUserModal, schoolUserModalOptions )
        .done(this.sendReviewPost).fail(this.sendReviewPost);
    } else {
      this.sendReviewPost();
    }
  }

  noSchoolUserExists(schoolUsers) {
    let state = this.props.state;
    let schoolId= this.props.schoolId;
    let matchingSchoolUsers = schoolUsers.filter(function(schoolUser) {
      return schoolUser.state === state && schoolUser.school_id === schoolId;
    });
    return matchingSchoolUsers.length === 0;
  }

  sendReviewPost(modalData) {
    let data = this.buildFormData();
    return $.ajax({
      url: "/gsr/reviews",
      method: 'POST',
      data: data,
      dataType: 'json'
    }).done(this.handleSuccessfulSubmit).fail(this.handleFailSubmit);
  }

  handleFailSubmit(xhr, status, err) {
    let formErrors = JSON.parse(xhr.responseText);
    let reviewsErrors = formErrors.reviews[0];
    if (reviewsErrors) {
      this.updateReviewFormErrors(reviewsErrors);
    }
    this.setState({disabled: false});
  }

  scrollToTopOfReviews() {
    var offsetTop = 90;
    var reviewListOffset = $('.review-list').offset().top;
    var offset = reviewListOffset - offsetTop;
    $('html, body').animate({
      scrollTop: offset
    }, 1000);
  }

  handleSuccessfulSubmit(xhr) {
    let reviews = xhr.reviews;
    let reviewSaveMessage = xhr.message;
    let userReviews = xhr.user_reviews;
    let reviewsErrors = this.reviewsErrors(reviews);
    if (reviewsErrors) {
      this.updateReviewFormErrors(reviewsErrors);
    } else {
      this.props.handleReviewSubmitMessage(reviewSaveMessage);
      this.props.handleUpdateOfReviews(userReviews);
      this.setState({disabled: false});
      this.hideQuestions();
      this.scrollToTopOfReviews();
    }
    this.setState({
      unsavedChanges: false
    });
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
    let guidelinesLink = gon.links.school_review_guidelines;
    let submitText;
    if (this.state.disabled) {
     submitText = 'Submitting';
    } else {
      submitText = 'Submit';
    }
    return(
      <div className="form-actions clearfix">
        <a href={guidelinesLink} target="_blank">Review Guidelines</a>
        <button className="button" onClick={this.cancelForm}>Cancel</button>
        <button className="button cta"
          disabled= {this.state.disabled}
          onClick={this.submitForm}>
          {submitText}
        </button>
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
    let reviewForm = (
      <div className="review-form-container">
        <div className="review-form">
          { this.state.displayCTA ? this.renderFiveStarQuestionCTA() : null }
          { this.state.displayAllQuestions ? this.renderQuestions() : null }
          { this.state.displayAllQuestions ? this.renderFormActions() : null }
        </div>
      </div>
    );

    if(this.state.disabled) {
      return (<SpinnyWheel
        backgroundPosition = { 'bottom' }
        content = { reviewForm }
      />);
    } else {
      return reviewForm;
    }
    return null;
  }
}

ReviewForm.propTypes = {
  state: React.PropTypes.string.isRequired,
  schoolId: React.PropTypes.number.isRequired,
  questions: React.PropTypes.arrayOf(React.PropTypes.shape({
    id: React.PropTypes.number.isRequired,
    title: React.PropTypes.string.isRequired,
    layout: React.PropTypes.string.isRequired,
    response_values: React.PropTypes.arrayOf(React.PropTypes.string).isRequired,
    response_labels: React.PropTypes.arrayOf(React.PropTypes.string).isRequired
  })).isRequired,
  handleReviewSubmitMessage: React.PropTypes.func.isRequired,
  handleUpdateOfReviews: React.PropTypes.func.isRequired
};
