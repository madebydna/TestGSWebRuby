import React from 'react';
import PropTypes from 'prop-types';
import { t } from '../../../util/i18n';

export default class SelectBoxes extends React.Component {

  static propTypes = {
    value: PropTypes.string,
    responseValues: PropTypes.arrayOf(PropTypes.string).isRequired,
    responseLabels: PropTypes.arrayOf(PropTypes.string).isRequired,
    questionId: PropTypes.number.isRequired,
    onClick: PropTypes.func.isRequired
  };

  constructor(props) {
    super(props);
    this.handleBoxClick = this.handleBoxClick.bind(this);
    this.convertValueToClassName = this.convertValueToClassName.bind(this);
  }

  handleBoxClick(value) {
    return () => this.props.onClick(value, this.props.questionId)
  }

  selectBoxes(value) {
    let boxes = [];
    for (var index= 0; index < this.props.responseValues.length; index++) {
      let selectionValue = this.props.responseValues[index];
      let selectionLabel = this.props.responseLabels[index];
      let classNames = this.convertValueToClassName(selectionValue);
      if (value === selectionValue) {
        classNames += " active";
      }
      boxes.push(
        <li onClick={this.handleBoxClick(selectionValue)} className='review-selection-item' key={index}>
          <span className={classNames}><span className={this.convertIndexToIconClass(index)}></span></span>
          <label>{selectionLabel}</label>
        </li>);
    }

    return(
      <ul className="review-selector clearfix">
        { boxes }
      </ul>
    );
  }

  convertIndexToIconClass(index) {
    let iconClass = "";
    if (index <= 1) {
      iconClass = "icon-dislike";
    } else if (index === 2) {
      iconClass = "icon-neutral";
    } else if (index >= 3) {
      iconClass = "icon-like";
    }
    return iconClass;
  }

  convertValueToClassName(value) {
   return value.replace(' ','-').toLowerCase();
  }

  render() {
    return (
      <div className="clearfix">
        {this.selectBoxes(this.props.value)}
      </div>
    )
  }
}
