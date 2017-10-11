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
  }

  render() {
    return <div>
      <ConnectedReviewDistributionModal
        question='This school effectively supports students with <span class="blue-highlight">learning differences</span>:'
        questionId={11}
      />
    </div>;
  }
}
