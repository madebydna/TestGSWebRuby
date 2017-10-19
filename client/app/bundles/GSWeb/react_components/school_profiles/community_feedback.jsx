import React from 'react';
import PropTypes from 'prop-types'; // importing from react is deprecated
import ConnectedReviewDistributionModal from 'react_components/connected_review_distribution_modal';
import Question from '../review/form/question';
import SelectBoxes from '../review/form/select_boxes';
import { isSignedIn } from '../../util/session';
import modalManager from '../../components/modals/manager';
import { getCurrentSession } from '../../api_clients/session';
import { withCurrentSchool } from '../../store/appStore';
import { postReview } from '../../api_clients/reviews';

export default class CommunityFeedback extends React.Component {

  constructor(props) {
    super(props)
    this.state = {
      failed: false,
      saved: false
    }

    this.responseSelected = this.responseSelected.bind(this);
    this.onSubmit = this.onSubmit.bind(this);
    this.textValueChanged = this.textValueChanged.bind(this);
    this.ensureSchoolUser = this.ensureSchoolUser.bind(this);
    this.handleReviewJoinModalFailure = this.handleReviewJoinModalFailure.bind(this);
    this.handleSchoolUserModalFailure = this.handleSchoolUserModalFailure.bind(this);
    this.handleGetCurrentSessionFailure = this.handleGetCurrentSessionFailure.bind(this);
    this.sendReviewPost = this.sendReviewPost.bind(this);
    this.handleFailSubmit = this.handleFailSubmit.bind(this);
    this.handleSuccessfulSubmit = this.handleSuccessfulSubmit.bind(this);
  }

  moduleQuestion() {
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
    withCurrentSchool((state, id) => {
      return postReview({
        state: state,
        school_id: id,
        reviews_params: JSON.stringify([{
          review_question_id: 11,
          comment: this.state.textAreaValue,
          answer_value: this.state.selectedResponse
        }])
      })
      .done(this.setState({errors: [], saved: true}))
      .fail(this.handleFailSubmit);
    });
  }

  handleFailSubmit(errors = []) {
    this.setState({errors: errors})
  }

  handleSuccessfulSubmit({reviews, message, user_reviews} = {}) {
    this.setState({errors: [], saved: true})
  }

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
  }

  onSubmit() {
    this.clearErrors();
    this.submitForm();
    this.setState(
      {
        formSubmittedSuccessfully: true
      }
    );
  }

  clearErrors() {
    this.setState({
      errorMessages: {},
      formErrors: false
    });
  }

  submitForm() {
    this.setState({disabled: true});
    if (isSignedIn()) {
      getCurrentSession()
        .done(this.ensureSchoolUser)
        .fail(this.handleGetCurrentSessionFailure);
    } else {
      modalManager.showModal('SubmitReviewModal')
        .done(({user} = {}) => this.ensureSchoolUser(user))
        .fail(this.handleReviewJoinModalFailure);
    }
  }

  ensureSchoolUser({school_users} = {}) {
    withCurrentSchool(function(state, schoolId) {
      if(this.noSchoolUserExists(school_users)) {
        modalManager.showModal('SchoolUserModal', ({state, schoolId}) )
          .done(this.sendReviewPost)
          .fail(this.handleSchoolUserModalFailure);
      } else {
        this.sendReviewPost();
      }
    }.bind(this));
  }

  handleGetCurrentSessionFailure(errorsArray = []) {
    this.setState({
      disabled: false,
      errorMessages: errorsArray
    });
  }

  handleReviewJoinModalFailure() {
    this.setState({
      disabled: false,
      errorMessages: ['Something went wrong logging you in']
    });
  }

  handleSchoolUserModalFailure(error) {
    this.setState({
      disabled: false,
      errorMessages: ['Something went wrong logging you in']
    });
  }

  noSchoolUserExists(schoolUsers) {
    let state = this.props.state;
    let schoolId= this.props.schoolId;
    let matchingSchoolUsers = schoolUsers.filter(function(schoolUser) {
      return schoolUser.state === state && schoolUser.school_id === schoolId;
    });
    return matchingSchoolUsers.length === 0;
  }

  renderSuccess() {
    return (
      <div style={{backgroundColor: "#D5FDD5", fontFamily: 'opensans-regular', padding: '15px 10px'}}>
      All set! We have submitted your review. Thank you for helping other families by sharing your experiences!
    </div>
    );
  }

  submitButton() {
    return (
      <div className="form-actions clearfix">
        <button className="button cta js-gaClick"
                data-ga-click-label="Students with disabilities - 11"
                data-ga-click-action="Post subtopic review"
                data-ga-click-category="Profile"
                onClick={this.onSubmit}>Submit</button>
      </div>
    );
  }

  renderErrors() {
    if (this.state.errors) {
      return (
        <div style={{color: 'red'}}>
          {this.state.errors['11']}
        </div>
      )
    }
  }

  render() {
    let success;
    let showSubmitButton;

    if (this.state.saved === true && this.state.errors.length === 0) {
      success = this.renderSuccess();
    } else {
      showSubmitButton = this.submitButton();
    }

    return (<div className="review-questions review-form-container">
      {success}
      {this.moduleQuestion()}
      {this.renderErrors()}
      {showSubmitButton}

      <ConnectedReviewDistributionModal
        question='This school effectively supports students with <span class="blue-highlight">learning differences</span>:'
        questionId={11}
        gaLabel="Students with disabilities - 11"
        gaAction="View subtopic responses"
      />
    </div>);
  }
}
