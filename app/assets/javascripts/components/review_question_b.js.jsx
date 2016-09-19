class ReviewQuestionB extends React.Component {
  constructor(props) {
    super(props);
  }

  render() {
    let pencilColor = {
      color: '#999999'
    }
    return (
      <div className="review-question clearfix">
        <div>
          <div className="review-counter"><span>{ this.props.id }</span></div>
        </div>
        <div>
          <div>
            { this.props.title }
          </div>
          <div className="clearfix">
            <ul className="review-selector clearfix">
              <li className="strongly-disagree"><span className="icon-dislike"></span></li>
              <li className="disagree"><span className="icon-dislike"></span></li>
              <li className="neutral"><span className="icon-neutral"></span></li>
              <li className="agree"><span className="icon-like"></span></li>
              <li className="strongly-agree"><span className="icon-like"></span></li>
            </ul>
            <ul className="review-select-name">
              <li>strongly disagree</li>
              <li>disagree</li>
              <li>neutral</li>
              <li>agree</li>
              <li>strongly agree</li>
            </ul>
          </div>
          <div className="tell-us-why">
            <div className="tell-us-link"><span className="icon-pencil" style={pencilColor}></span> Tell us why&hellip;</div>
            <div className="tell-us-text"><textarea className="js-comment"></textarea></div>
          </div>
        </div>
      </div>
    )
  }
}
