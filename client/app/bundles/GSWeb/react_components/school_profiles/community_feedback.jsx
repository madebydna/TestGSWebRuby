import React from 'react';
import PropTypes from 'prop-types'; // importing from react is deprecated
import ConnectedReviewDistributionModal from 'react_components/connected_review_distribution_modal';
import Question from '../review/form/question';
import SelectBoxes from '../review/form/select_boxes';
import {isSignedIn} from 'util/session';
import modalManager from 'components/modals/manager';

export default class CommunityFeedback extends React.Component {

  static propTypes = {

  };

  static defaultProps = {

  };

  constructor(props) {
    super(props)
    this.state = {
      failed: false,
      saved: false
    }

    this.responseSelected = this.responseSelected.bind(this);
    this.onSubmit = this.onSubmit.bind(this);
    this.textValueChanged = this.textValueChanged.bind(this);
  }

  mockQuestion() {
    return (
      <Question id = {11}
                subtext = {"Do you feel this school effectively supports students with learning differences?"}
                questionCounter = {1}
                title = {"Share your feedback"}
                layout = {<SelectBoxes
                  value = {this.state.selectedResponse}
                  responseValues = {['Strongly disagree','Disagree','Neutral','Agree','Strongly agree']}
                  responseLabels = {['Strongly disagree','Disagree','Neutral','Agree','Strongly agree']}
                  questionId = {11}
                  onClick = {this.responseSelected}
                />}
                shouldDisplayTextArea = {true}
                errorMessage = { "" }
                value = {this.state.selectedResponse}
                textValueChanged = {this.textValueChanged}
      />
    )
  }

  sendReviewPost(modalData) {
    return postReview(this.buildFormData())
      .done(this.handleSuccessfulSubmit)
      .fail(this.handleFailSubmit);
  }

  buildFormData() {
    return {
      review_question_id: 11,
      comment: this.state.textAreaValue,
      answer_value: this.state.selectedResponse
    };
  }


  handleFailSubmit(errorsObject) {
    setState({errors: errorsObject})
  }

  handleSuccessfulSubmit({reviews, message, user_reviews} = {}) {
    setState({errors: {}, saved: true})
  }



  // TODO: render something when there are errors



  responseSelected(value, id) {
    this.setState(
      {
        selectedResponse: value,
        unsavedChanges: true
      }
    );
  }

  textValueChanged(value, id) {
    this.setState(
      {
        unsavedChanges: true,
        textAreaValue: value
      }
    );
    // this.validateForm();
  }

  onSubmit() {
    this.clearErrors();
    // var formValid = this.validateForm();
    // if (formValid) {
      this.submitForm();
      this.setState(
        {
          formSubmittedSuccessfully: true
        }
      );
    // }
  }

  clearErrors() {
    this.setState({
      errorMessages: {},
      formErrors: false
    });
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
    var selectedResponses = this.state.selectedResponse;
    var errorMessages = reduce(selectedResponses, this.validateResponse, {});
    var formValid = isEmpty(errorMessages);
    this.setState ({
      errorMessages: errorMessages,
      formErrors: !formValid
    });
    return formValid;
  }


  submitForm() {
    this.setState({disabled: true});
    if (isSignedIn()) {
      getCurrentSession().done(this.getSchoolUser).fail(this.sendReviewPost);
    } else {
      modalManager.showModal('SubmitReviewModal')
        .done(this.getSchoolUser)
        .fail(function() {
          this.updateReviewFormErrors({
            '1': 'Something went wrong logging you in'
          });
        }.bind(this));
    }
  }

  renderSuccess() {
    return (
      <div style={{backgroundColor: "#D5FDD5", fontFamily: 'opensans-regular', padding: '15px 10px'}}>
      All set! We have submitted your review. Thank you for helping other families by sharing your experiences!
    </div>
    );
  }

  render() {
    let success;
    if (this.state.formSubmittedSuccessfully) {
      success = this.renderSuccess();
    }
    return (<div className="review-questions review-form-container">
      {success}
      {this.mockQuestion()}

      <div className="form-actions clearfix">
        <button className="button cta" onClick={this.onSubmit}>Submit</button>
      </div>

      <ConnectedReviewDistributionModal
        question='This school effectively supports students with <span class="blue-highlight">learning differences</span>:'
        questionId={11}
      />
    </div>);
  }
}
