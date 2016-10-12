class Reviews extends React.Component {
  constructor(props) {
    super(props);
    var currentUserReportedMap = {};
    // TODO: This needs to be hooked up somewhere. Maybe from props?
    this.state = {currentUserReportedMap: currentUserReportedMap};
    this.renderReviewLayout = this.renderReviewLayout.bind(this);
    this.renderReviewForm = this.renderReviewForm.bind(this);
    this.renderReviewsList = this.renderReviewsList.bind(this);
  }

  renderReviewsList() {
    return(<ReviewsList
      reviews = { this.props.reviews }
    />);
  }

  renderReviewForm() {
    return(<ReviewForm
      state = { this.props.state }
      schoolId = { this.props.schoolId }
      questions = { this.props.questions }
    />);
  }

  renderReviewLayout(componentFunction, title) {
    let reviewsSectionStyle = { 'marginTop': '30px' }
    return(
      <div style={reviewsSectionStyle}>
        <div className="rating-container">
          <div className="row">
            <div className="col-xs-12 col-lg-3">
              <div className="rating-container__title">
                { title }
              </div>
            </div>
            <div className="col-xs-12 col-lg-9">
              { componentFunction() }
            </div>
          </div>
        </div>
      </div>
    );
  }

  render() {
    return (
      <div>
        <a name="Reviews"></a>
        { this.renderReviewLayout(this.renderReviewForm, 'Review this school') }
        { this.renderReviewLayout(this.renderReviewsList, 'Recent Comments') }
      </div>
    );
  }
}
