class SelectBoxes extends React.Component {
  constructor(props) {
    super(props);
    this.handleBoxClick = this.handleBoxClick.bind(this);
    this.convertValueToClassName = this.convertValueToClassName.bind(this);
  }

  handleBoxClick(value) {
    return () => this.props.onClick(value, this.props.question_id)
  }

  selectBoxes(value) {
    let values = [
      "Strongly disagree",
      "Disagree",
      "Neutral",
      "Agree",
      "Strongly agree"
    ];
    boxes = [];
    for (var index= 0; index < values.length; index++) {
      let selectionValue = values[index];
      let classNames = this.convertValueToClassName(selectionValue);
      if ( value === selectionValue) {
        classNames += " active";
      }
      boxes.push(<li className={classNames} onClick={this.handleBoxClick(selectionValue)}><span className={this.convertIndexToIconClass(index)}></span></li>);
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
        {this.selectBoxes(this.props.selectedValue)}
        <ul className="review-select-name">
          <li>strongly disagree</li>
          <li>disagree</li>
          <li>neutral</li>
          <li>agree</li>
          <li>strongly agree</li>
        </ul>
      </div>
    )
  }
}
