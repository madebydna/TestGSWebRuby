import React, { PropTypes } from 'react';

export default class SelectBoxes extends React.Component {

  static propTypes = {
    value: React.PropTypes.string,
    responseValues: React.PropTypes.arrayOf(React.PropTypes.string).isRequired,
    responseLabels: React.PropTypes.arrayOf(React.PropTypes.string).isRequired,
    questionId: React.PropTypes.number.isRequired,
    onClick: React.PropTypes.func.isRequired
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
      let classNames = this.convertValueToClassName(selectionValue);
      if (value === selectionValue) {
        classNames += " active";
      }
      boxes.push(<li key={index} className={classNames} onClick={this.handleBoxClick(selectionValue)}><span className={this.convertIndexToIconClass(index)}></span></li>);
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

  renderResponseLabels() {
    let labels = [];
    this.props.responseLabels.forEach(function(label, index) {
      labels.push(<li key={index}>{label}</li>);
    });
    return(
      <ul className="review-select-name">
        { labels }
      </ul>
    );
  }

  render() {
    return (
      <div className="clearfix">
        {this.selectBoxes(this.props.value)}
        {this.renderResponseLabels()}
      </div>
    )
  }
}
