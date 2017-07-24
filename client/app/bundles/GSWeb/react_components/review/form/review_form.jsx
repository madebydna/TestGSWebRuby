import React, { PropTypes } from 'react';
import FiveStarQuestionCTA from './five_star_question_cta';
import Questions from './questions';
import SpinnyWheel from '../../spinny_wheel';
import { scrollToElement } from '../../../util/scrolling';

export default class ReviewForm extends React.Component {

  static propTypes = {
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
    this.onSubmit = this.onSubmit.bind(this);
    this.handleFailSubmit = this.handleFailSubmit.bind(this);
    this.promptUserWhenNavigatingAway = this.promptUserWhenNavigatingAway.bind(this);
    this.validateResponse = this.validateResponse.bind(this)
    window.onbeforeunload = this.promptUserWhenNavigatingAway;
    
    this.state = {
      displayCTA: true,
      displayAllQuestion: false,
      selectedResponses: {},
      formErrors: false,
      errorMessages: {},
      selectedFiveStarResponse: null,
      unsavedChanges: false,
      disabled: false
    };
  }

  promptUserWhenNavigatingAway(e) {
    if (this.state.unsavedChanges) {
      e.returnValue = GS.I18n.t('review_not_saved');
      return e.returnValue;
    }
  }

  renderFiveStarQuestionCTA() {
    let fiveStarQuestion = this.props.questions[0];
    if(fiveStarQuestion === undefined) {
      return undefined;
    }
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
    scrollToElement('.review-summary');
  }

  fiveStarQuestionSelect(value, id) {
    analyticsEvent('Profile', 'Reviews Star Rated');
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
    this.validateForm();
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

  minWordsValidator(string) {
    if (! string) {
      return null;
    }
    var numberWords = string
      .replace( /(^\s*)|(\s*$)/gi, "" )
      .replace( /[ ]{2,}/gi, " " )
      .replace( /\n /, "\n" )
      .split(' ').length;
    if (7 > numberWords) {
      return GS.I18n.t('review_word_min');
    } else {
      return null;
    }
  }

  requiredCommentValidator(string) {
    if ( !string || string.length == 0) {
      return GS.I18n.t('review_thank_you');
    } else {
      return null;
    }
  }

  maxCharactersValidator(string) {
    if (string && string.legnth != 0 && string.length > 2400) {
      return GS.I18n.t('review_char_limit');;
    } else {
      return null;
    }
  }

  clearErrors() {
    this.setState({
      errorMessages: {},
      formErrors: false
    });
  }

  getValidationsForQuestion(questionId) {
    let validationFuncs = [];
    switch(questionId) {
      case "1": validationFuncs.push(this.requiredCommentValidator);
      default: validationFuncs.push(this.minWordsValidator);
              validationFuncs.push( this.maxCharactersValidator);
    }
    return validationFuncs;
  }

  errorMessageForQuestion(validationFuncs, comment) {
    var error;
    _.each(validationFuncs, function(func) {
      var message = func(comment);
      if (message) {
        error = message;
        return false;
      }
    });
    return error;
  }

  validateResponse(errorMessages, response, questionId) {
    var comment = response.comment;
    var validationFuncs = this.getValidationsForQuestion(questionId);
    var message = this.errorMessageForQuestion(validationFuncs, comment);
    if (message) {
      errorMessages[questionId] = message;
    }
    return errorMessages;
  }

  validateForm() {
   var selectedResponses = this.state.selectedResponses;
   var errorMessages = _.reduce(selectedResponses, this.validateResponse, {});
   var formValid = _.isEmpty(errorMessages);
    this.setState ({
      errorMessages: errorMessages,
      formErrors: !formValid
    });
    return formValid;
  }

  onSubmit() {
    this.clearErrors();
    var formValid = this.validateForm();
    if (formValid) {
      this.submitForm();
    }
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

  renderFormErrorMessage() {
    return(
      <div className='form-error'>Errors in Form</div>
    );
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
        <a href={guidelinesLink} target="_blank">{GS.I18n.t('Review Guidelines')}</a>
        <button className="button" onClick={this.cancelForm}>{GS.I18n.t('Cancel')}</button>
        <button className="button cta"
          disabled= {this.state.disabled}
          onClick={this.onSubmit}>
          {GS.I18n.t(submitText)}
        </button>
        {/* { this.state.formErrors ? this.renderFormErrorMessage() : null } */}
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
