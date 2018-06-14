import React from 'react';
import PropTypes from 'prop-types';
import FiveStarQuestionCTA from './five_star_question_cta';
import Questions from './questions';
import SpinnyWheel from '../../spinny_wheel';
import { scrollToElement } from '../../../util/scrolling';
import { t } from '../../../util/i18n';
import { isSignedIn } from '../../../util/session';
import { getCurrentSession } from 'api_clients/session';
import modalManager from '../../../components/modals/manager';
import { forOwn, each, isEmpty } from 'lodash';
import { postReview } from 'api_clients/reviews';

export default class ReviewForm extends React.Component {

  static propTypes = {
    state: PropTypes.string.isRequired,
    schoolId: PropTypes.number.isRequired,
    questions: PropTypes.arrayOf(PropTypes.shape({
      id: PropTypes.number.isRequired,
      title: PropTypes.string.isRequired,
      layout: PropTypes.string.isRequired,
      response_values: PropTypes.arrayOf(PropTypes.string).isRequired,
      response_labels: PropTypes.arrayOf(PropTypes.string).isRequired
    })).isRequired,
    handleReviewSubmitMessage: PropTypes.func.isRequired,
    handleUpdateOfReviews: PropTypes.func.isRequired
  };

  constructor(props) {
    super(props);
    this.fiveStarQuestionSelect = this.fiveStarQuestionSelect.bind(this);
    this.responseSelected = this.responseSelected.bind(this);
    this.cancelForm = this.cancelForm.bind(this);
    this.submitForm = this.submitForm.bind(this);
    this.textValueChanged = this.textValueChanged.bind(this);
    this.sendReviewPost = this.sendReviewPost.bind(this);
    this.ensureSchoolUser = this.ensureSchoolUser.bind(this);
    this.updateReviewFormErrors = this.updateReviewFormErrors.bind(this);
    this.noSchoolUserExists = this.noSchoolUserExists.bind(this);
    this.handleSuccessfulSubmit = this.handleSuccessfulSubmit.bind(this);
    this.onSubmit = this.onSubmit.bind(this);
    this.handleFailSubmit = this.handleFailSubmit.bind(this);
    this.promptUserWhenNavigatingAway = this.promptUserWhenNavigatingAway.bind(this);
    this.validateResponse = this.validateResponse.bind(this)
    this.handleGetCurrentSessionFailure = this.handleGetCurrentSessionFailure.bind(this);
    this.handleReviewJoinModalFailure = this.handleReviewJoinModalFailure.bind(this);
    this.handleSchoolUserModalFailure = this.handleSchoolUserModalFailure.bind(this);
    window.onbeforeunload = this.promptUserWhenNavigatingAway;
    
    this.state = {
      displayCTA: true,
      displayAllQuestion: false,
      selectedResponses: {},
      formErrors: false,
      errorMessages: {},
      selectedFiveStarResponse: null,
      unsavedChanges: false,
      disabled: false,
      submittingForm: false
    };
  }

  promptUserWhenNavigatingAway(e) {
    if (this.state.unsavedChanges) {
      e.returnValue = t('review_not_saved');
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
    forOwn(selectedResponses, function (reviewResponse, questionId) {
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
      return t('review_word_min');
    } else {
      return null;
    }
  }

  requiredCommentValidator(string) {
    if ( !string || string.length == 0) {
      return t('review_thank_you');
    } else {
      return null;
    }
  }

  maxCharactersValidator(string) {
    if (string && string.length != 0 && string.length > 2400) {
      return t('review_char_limit');;
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
      case "1": if (this.state.submittingForm == true) {validationFuncs.push(this.requiredCommentValidator);}
      default: validationFuncs.push(this.minWordsValidator);
              validationFuncs.push( this.maxCharactersValidator);
    }
    return validationFuncs;
  }

  errorMessageForQuestion(validationFuncs, comment) {
    var error;
    each(validationFuncs, function(func) {
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
   var errorMessages = Object.keys(selectedResponses).reduce((accum, questionId) => {
     return this.validateResponse(accum, selectedResponses[questionId], questionId)
   }, {});
   var formValid = isEmpty(errorMessages);
   this.setState({errorMessages: errorMessages, formErrors: !formValid});
   return errorMessages
  }

  validateAndSubmit(){
    let errorMessages = this.validateForm();
    let formValid = isEmpty(errorMessages);
    if(!formValid) {
      analyticsEvent('Profile', 'Display Error Message', 'Review form validation failed');
      this.scrollToFirstError(errorMessages);
    } else if (formValid) {
      this.submitForm();
    }
    this.setState({submittingForm: false})
  }

  scrollToFirstError(errorMessages) {
    let errorMessageKeys = Object.keys(errorMessages);
    let orderedQuestions = this.reorderedQuestionIds();

    let errorId=orderedQuestions.find(function(questionId){return errorMessageKeys.indexOf(questionId.toString())>=0});
    // question_1 shows up twice on page (star rating and textarea), so scroll to lower one (where error is printed)
    if (errorId == 1) {errorId += ':last-of-type'}
    scrollToElement('.question_' + errorId);
  }

  reorderedQuestionIds() {
    // this function preserves the order of review questions displayed on the page so scrollToFirstError can find
    // and scroll to the first error, with the exception of question 1, which should always be last.
    let idArray = this.props.questions.map(question => question.id);
    let indexOfOne = idArray.indexOf(1);
    if (indexOfOne >= 0) {
      idArray.splice(indexOfOne, 1);
      idArray.push(1);
    }
    return idArray
  }

  onSubmit() {
    this.clearErrors();
    this.setState({submittingForm: true}, () => this.validateAndSubmit());
  }

  handleGetCurrentSessionFailure(errorsArray = []) {
    this.setState({
      disabled: false,
      errorMessages: {
        '1': errorsArray[0]
      }
    });
  }

  handleReviewJoinModalFailure(error = 'Something went wrong logging you in') {
    if(error == 'closed') {
      error = 'You\'re review won\'t be saved until you click the submit button and log in.';
    }
    this.setState({
      disabled: false,
      errorMessages: {
        '1': error
      }
    });
  }

  submitForm() {
    this.setState({disabled: true});
    if (isSignedIn()) {
      getCurrentSession()
        .done(this.ensureSchoolUser)
        .fail(this.handleGetCurrentSessionFailure);
    } else {
      let joinModalOptions =  {
        state: this.props.state,
        schoolId: this.props.schoolId.toString()
      };
      modalManager.showModal('SubmitReviewModal', joinModalOptions)
        .done(({user} = {}) => this.ensureSchoolUser(user))
        .fail(this.handleReviewJoinModalFailure);
    }
  }

  handleSchoolUserModalFailure(error) {
    this.setState({
      disabled: false,
      errorMessages: {
        '1': 'Something went wrong logging you in'
      }
    });
  }

  ensureSchoolUser({school_users} = {}) {
    let schoolUserModalOptions =  {
      state: this.props.state,
      schoolId: this.props.schoolId.toString()
    };
    if(this.noSchoolUserExists(school_users)) {
      modalManager.showModal('SchoolUserModal', schoolUserModalOptions )
        .done(this.sendReviewPost)
        .fail(this.handleSchoolUserModalFailure);
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

  sendReviewPost() {
    return postReview(this.buildFormData())
      .done(this.handleSuccessfulSubmit)
      .fail(this.handleFailSubmit);
  }

  handleFailSubmit(errorsArray = ['An error occured while saving your review']) {
    this.setState({
      disabled: false,
      errorMessages: {
        '1': errorsArray[0]
      }
    });
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
    forOwn(reviews, function (review, questionId) {
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
        <a href={guidelinesLink} target="_blank">{t('Review Guidelines')}</a>
        <button className="button" onClick={this.cancelForm}>{t('Cancel')}</button>
        <button className="button cta"
          disabled= {this.state.disabled}
          onClick={this.onSubmit}>
          {t(submitText)}
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
