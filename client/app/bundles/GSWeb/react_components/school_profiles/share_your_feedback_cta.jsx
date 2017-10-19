import React from 'react';
import PropTypes from 'prop-types';
import { t } from '../../util/i18n';
import AnchorButton from 'react_components/anchor_button';
import ConnectedReviewDistributionModal from 'react_components/connected_review_distribution_modal';

const ShareYourFeedbackCta = ({questionText, buttonClicked}) => {
  return (
    <div className="share-your-feedback-cta">
      <hr/>
      <p className="parent-tip">
        <img src="/assets/school_profiles/owl.png" />
        <span className="speech-bubble left">Share your feedback</span>
      </p>
      <p>{questionText}</p>
      <div className="actions">
        <AnchorButton href="javascript:void(0)" onClick={buttonClicked}>Answer</AnchorButton>
        <ConnectedReviewDistributionModal
          question='This school effectively supports students with <span class="blue-highlight">learning differences</span>:'
          questionId={11}
        />
      </div>
    </div>
  );
};

ShareYourFeedbackCta.PropTypes = {
  questionText: PropTypes.string.isRequired,
  buttonClicked: PropTypes.func.isRequired
}

export default ShareYourFeedbackCta;
