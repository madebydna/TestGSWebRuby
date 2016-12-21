import React, { PropTypes } from 'react';
import SpinnyWheel from '../spinny_wheel';

export default class ReportReview extends React.Component {

  static propTypes = {
    review: React.PropTypes.object.isRequired,
    open: React.PropTypes.bool,
    cancelCallback: React.PropTypes.func.isRequired,
    reportedCallback: React.PropTypes.func.isRequired
  };

  constructor(props) {
    super(props);
    this.state = {value: '', error: null, notice: null, disabled: false};
    this.postReviewReport = this.postReviewReport.bind(this);
    this.handleCancelClick = this.handleCancelClick.bind(this);
    this.handleSubmitClick = this.handleSubmitClick.bind(this);
    this.handleChange = this.handleChange.bind(this);
    this.handleSuccessfulSubmit = this.handleSuccessfulSubmit.bind(this);
    this.handleFailedSubmit = this.handleFailedSubmit.bind(this);
  }

  handleCancelClick(event) {
    event.preventDefault();
    this.props.cancelCallback();
  }

  handleSuccessfulSubmit() {
    this.props.reportedCallback();
  }

  handleFailedSubmit(data) {
    if (data && data.responseJSON && data.responseJSON.flash) {
      let flash_response = data.responseJSON.flash;
      if (flash_response.error) {
        this.setState({error: data.responseJSON.flash.error});
      } else if (flash_response.notice) {
        this.setState({notice: data.responseJSON.flash.notice});
      } else {
        this.setState({error: "Something went wrong. Please try again later or contact us directly."})
      }
    } else {
      this.setState({error: "Something went wrong. Please try again later or contact us directly."})
    }
  }

  postReviewReport() {
    this.setState({disabled: true});
    let review = this.props.review;
    let comment = this.state.value;
    let data = {
      id: review.id,
      review_flag: {comment: comment}
    };
    return $.ajax({
      url: review.links.flag,
      method: 'POST',
      data: data,
      dataType: 'json'
    }).done(this.handleSuccessfulSubmit).fail(this.handleFailedSubmit).always(function() {
      this.setState({disabled: false});
    }.bind(this));
  }

  handleSubmitClick(event) {
    event.preventDefault();

    if (this.state.disabled) {
      return;
    }

    if (this.state.value) {
      this.setState({error: null, notice: null});

      if (GS.session.isSignedIn()) {
        this.postReviewReport();
      } else {
        GS.modal.manager.showModal(GS.modal.ReportReviewModal)
            .done(this.postReviewReport)
            .fail(function() {
              this.setState({error: 'Something went wrong logging you in'});
            }.bind(this));
      }
    } else {
      this.setState({error: 'Please enter a reason'});
    }
  }

  handleChange(event) {
    this.setState({value: event.target.value});
  }

  renderError() {
    if (this.state.error) {
      return (<p className="error">{this.state.error}</p>);
    }
  }

  renderNotice() {
    if (this.state.notice) {
      return (<p className="notice">{this.state.notice}</p>);
    }
  }

  render() {
    if (this.props.open === true) {
      let termsLink = gon.links.terms_of_use;
      let guidelinesLink = gon.links.school_review_guidelines;
      let spinnyClass = "js-report-review-" + this.props.review.id;
      let reportForm = (
          <div className={'report-review ' + spinnyClass}>
            <form>
              <p className="header">Report this review as inappropriate</p>
              <p>Please explain how this review may have violated
                our <a href={termsLink} target="_blank">terms of use
                </a> or <a href={guidelinesLink} target="_blank">school review guidelines</a>
              </p>
              { this.renderNotice() }
              { this.renderError() }
              <textarea value={this.state.value} onChange={this.handleChange}/>
              <div className="form-actions">
                <span className="button" onClick={this.handleCancelClick}>Cancel</span>
                <span className="button cta" onClick={this.handleSubmitClick}>Submit</span>
              </div>
            </form>
          </div>
      );

      if (this.state.disabled) {
        return(<SpinnyWheel
          content = { reportForm }
        />);
      }
      return reportForm;
    }
    return null;
  }
}
