import React from 'react';
import PropTypes from 'prop-types';
import Question from './question';
import FiveStarRating from './five_star_rating';
import SelectBoxes from './select_boxes';
import TextArea from './text_area';
import { t } from '../../../util/i18n';

export default class Questions extends React.Component {

  static propTypes = {
    questions: PropTypes.arrayOf(PropTypes.shape({
      id: PropTypes.number.isRequired,
      title: PropTypes.string.isRequired,
      layout: PropTypes.string.isRequired,
      response_values: PropTypes.arrayOf(PropTypes.string).isRequired,
      response_labels: PropTypes.arrayOf(PropTypes.string).isRequired
    })).isRequired,
    selectedResponses: PropTypes.object.isRequired,
    responseSelected: PropTypes.func.isRequired,
    errorMessages: PropTypes.object.isRequired,
    textValueChanged: PropTypes.func
  };

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
        questionId = {question.id}
        onClick = {this.props.responseSelected}
      />)
    } else {
      component = (<SelectBoxes
        value = {selectedValue}
        responseValues = {question.response_values}
        responseLabels = {question.response_labels}
        questionId = {question.id}
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
    let responseKey = question.id.toString();
    let commentValue;
    if (this.props.selectedResponses[responseKey]) {
      commentValue = this.props.selectedResponses[responseKey].comment;
    }
    let layoutComponent = (<TextArea
      questionId = {question.id}
      onTextValueChanged = {this.props.textValueChanged}
      errorMessage = { this.props.errorMessages[question.id] }
      textValue = { commentValue }
    />)
    return(<Question
      id = {question.id}
      subtext = { t("Required") }
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
    let commentValue;
    if (this.props.selectedResponses[responseKey]) {
      commentValue = this.props.selectedResponses[responseKey].comment;
    }
    return(<Question
      id = {question.id}
      key = {question.id}
      questionCounter = {index + 1}
      title = {question.title}
      value = {this.props.selectedResponses[responseKey]}
      layout = {layoutComponent}
      shouldDisplayTextArea = {shouldDisplayTextArea}
      textValueChanged = {this.props.textValueChanged}
      errorMessage = { this.props.errorMessages[responseKey] }
      textValue = { commentValue }
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
