class ReportReview extends React.Component {
  constructor(props) {
    super(props);
    this.state = {value: ''};
    this.handleCancelClick = this.handleCancelClick.bind(this);
    this.handleSubmitClick = this.handleSubmitClick.bind(this);
    this.handleChange = this.handleChange.bind(this);
  }

  handleCancelClick(event) {
    this.props.cancelCallback();
    event.preventDefault();
  }

  handleSubmitClick(event) {
    this.props.reportedCallback();
    event.preventDefault();
  }

  handleChange(event) {
    this.setState({value: event.target.value});
  }

  render() {
    if (this.props.open === true) {
      return (
          <div className="report-review">
            <form>
              <p className="header">Report this review as inappropriate</p>
              <p>Please explain how this review may have violated our terms of use or school review guidelines</p>
              <textarea value={this.state.value} onChange={this.handleChange}/>
              <div className="form-buttons">
                <span className="button" onClick={this.handleCancelClick}>Cancel</span>
                <span className="button cta" onClick={this.handleSubmitClick}>Submit</span>
              </div>
            </form>
          </div>
      );
    }
    return null;
  }
}

ReportReview.propTypes = {
  open: React.PropTypes.bool,
  cancelCallback: React.PropTypes.func,
  reportedCallback: React.PropTypes.func
};
