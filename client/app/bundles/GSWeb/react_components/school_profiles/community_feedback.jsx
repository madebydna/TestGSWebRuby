import React from 'react';
import PropTypes from 'prop-types'; // importing from react is deprecated
import ConnectedReviewDistributionModal from 'react_components/connected_review_distribution_modal';

export default class CommunityFeedback extends React.Component {

  static propTypes = {

  }

  static defaultProps = {

  }

  constructor(props) {
    super(props)
    this.state = {
      failed: false,
      saved: false
    }
  }

  sendReviewPost(modalData) {
    return postReview(this.buildFormData())
      .done(this.handleSuccessfulSubmit)
      .fail(this.handleFailSubmit);
  }

  buildFormData() {
    // serialize the data in the form that the user filled out
    // probably with jQuery.serialize(...)
  }

  handleFailSubmit(errorsObject) {
    setState({errors: errorsObject})
  }

  handleSuccessfulSubmit({reviews, message, user_reviews} = {}) {
    setState({errors: {}, saved: true})
  }

  // TODO: render something when "saved" is true
  // TODO: render something when there are errors
  // TODO: render the question and form and submit button
  render() {
    return <div>




      <ConnectedReviewDistributionModal
        question='This school effectively supports students with <span class="blue-highlight">learning differences</span>:'
        questionId={11}
      />
    </div>;
  }
}
