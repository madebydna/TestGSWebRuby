import React from 'react';
import PropTypes from 'prop-types';
import { TransitionGroup, CSSTransition } from 'react-transition-group';
import TextArea from './text_area';
import { t } from '../../../util/i18n';

export default class Question extends React.Component {
  static propTypes = {
    id: PropTypes.number.isRequired,
    questionCounter: PropTypes.number.isRequired,
    title: PropTypes.string.isRequired,
    subtext: PropTypes.string,
    layout: PropTypes.object.isRequired,
    shouldDisplayTextArea: PropTypes.bool,
    textValueChanged: PropTypes.func,
    errorMessage: PropTypes.string
  };

  constructor(props) {
    super(props);
    this.displayTextArea = this.displayTextArea.bind(this);
    this.handleTextBoxChange = this.handleTextBoxChange.bind(this);
    this.handleTextBlur = this.handleTextBlur.bind(this);
    this.handleTellUsWhyClick = this.handleTellUsWhyClick.bind(this);
    this.state = {
      shouldDisplayTextArea: this.props.textValue && this.props.textValue != '',
      shouldDisplayTellUsLink: !(
        this.props.textValue && this.props.textValue != ''
      ),
      textFocus: true
    };
  }

  renderLayout() {
    return this.props.layout;
  }

  displayTextArea() {
    this.setState({
      shouldDisplayTellUsLink: false,
      shouldDisplayTextArea: true
    });
  }

  handleTextBlur() {
    if (
      (!this.props.textValue || this.props.textValue == '') &&
      this.state.textValue
    ) {
      this.setState({
        shouldDisplayTextArea: false,
        shouldDisplayTellUsLink: true
      });
    }
  }

  renderErrorMessage() {
    return <div className="error-message">{this.props.errorMessage}</div>;
  }

  handleTellUsWhyClick() {
    this.setState({ textFocus: true });
    this.displayTextArea();
  }

  renderTextArea() {
    return (
      <TextArea
        questionId={this.props.id}
        onTextValueChanged={this.props.textValueChanged}
        handleTextBlur={this.handleTextBlur}
        autoFocus={this.state.textFocus}
        errorMessage={this.props.errorMessage}
        textValue={this.props.textValue}
        placeholder="Tell us why..."
      />
    );
  }

  handleTextBoxChange(event) {
    this.setState({ textValue: event.target.value });
    this.props.textValueChanged(event.target.value, this.props.id);
  }

  renderTellUsLink() {
    return (
      <div className="tell-us-link" onClick={this.handleTellUsWhyClick}>
        <span className="icon-pencil" />
        {t('Tell us why')}&hellip;
      </div>
    );
  }

  renderTellUsWhy() {
    return (
      <CSSTransition classNames="textarea" timeout={400}>
        <div className="tell-us-why">
          <div className="tell-us-text">
            <CSSTransition classNames="textarea" timeout={800}>
              <React.Fragment>
                {this.renderTextArea()}
                <div className="required-or-optional">Optional</div>
              </React.Fragment>
            </CSSTransition>
          </div>
        </div>
      </CSSTransition>
    );
  }

  renderSubtext() {
    return <div className="subtext">{this.props.subtext}</div>;
  }

  render() {
    return (
      <div
        className={`${'review-question clearfix ' + 'question_'}${
          this.props.id
        }`}
      >
        <div>
          <div className="review-counter">
            <span>{this.props.questionCounter}</span>
          </div>
        </div>
        <div>
          <div>
            <div dangerouslySetInnerHTML={{ __html: this.props.title }} />
            {this.props.subtext ? this.renderSubtext() : null}
          </div>
          {this.renderLayout()}
          <TransitionGroup>
            {this.props.value && this.props.shouldDisplayTextArea
              ? this.renderTellUsWhy()
              : null}
          </TransitionGroup>
        </div>
      </div>
    );
  }
}
