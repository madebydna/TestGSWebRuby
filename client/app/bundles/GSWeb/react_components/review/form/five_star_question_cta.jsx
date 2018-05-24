import React from 'react';
import PropTypes from 'prop-types';
import { t } from '../../../util/i18n';

export default class FiveStarQuestionCTA extends React.Component {

  static propTypes = {
    responseValues: PropTypes.arrayOf(PropTypes.string).isRequired,
    responseLabels: PropTypes.arrayOf(PropTypes.string).isRequired,
    id: PropTypes.number.isRequired,
    title: PropTypes.string.isRequired,
    fiveStarQuestionSelect: PropTypes.func.isRequired
  };

  constructor(props) {
    super(props);
    this.handleStarResponseClick = this.handleStarResponseClick.bind(this);
    this.renderStarResponse = this.renderStarResponse.bind(this);
  }

  renderStarResponses() {
    return this.props.responseLabels.map(this.renderStarResponse);
  }

  handleStarResponseClick(value) {
    return () => this.props.fiveStarQuestionSelect(value, this.props.id);
  }

  // consistify the grabbing of the selected value 
  renderStarResponse(label, index) {
    let starValue = this.props.responseValues[index];
    return(
      <div key={index} className="five-star-question-cta__response-container">
        <div onClick={this.handleStarResponseClick(parseInt(starValue))}>
          <div className="icon-star five-star-question-cta__star"></div>
          <div className="five-star-question-cta__response-label">{t(label)}</div>
        </div>
      </div>
    );
  }

  render() {
    return (
      <div  className="five-star-question-cta">
        <div className="row">
          <div className="col-xs-12 col-sm-2">
            <div className="five-star-question-cta__avatar icon-avatar-1"></div>
            <div className="five-star-question-cta__user-type">{t('You')}</div>
          </div>
          <div className="col-xs-12 col-sm-10 five-star-question-cta__container">
            <div className="five-star-question-cta__title">
              { this.props.title }
            </div>
            { this.renderStarResponses() }
          </div>
        </div>
      </div>
    )
  }
}
