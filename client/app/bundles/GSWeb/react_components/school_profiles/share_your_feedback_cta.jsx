import React from 'react';
import PropTypes from 'prop-types';
import { t } from '../../util/i18n';
import AnchorButton from 'react_components/anchor_button';
import ConnectedReviewDistributionModal from 'react_components/connected_review_distribution_modal';
import communityAvatar from 'icons/community-avatar.png';

const ShareYourFeedbackCta = ({questionText, buttonClicked}) => {
  return (
    <div className="share-your-feedback-cta">
      <hr/>
      <p className="parent-tip">
        <img src={communityAvatar} />
        <span className="speech-bubble left">{questionText}</span>
      </p>
      <div className="actions">
        <AnchorButton href="javascript:void(0)"
                      onClick={buttonClicked}
                      style={{display: 'inline-block'}}
                      className="clearfix js-subtopicAnswerButton">Answer
        </AnchorButton>
        <ConnectedReviewDistributionModal
          question='This school effectively supports students with <span class="blue-highlight">learning differences</span>:'
          questionId={11}
          gaLabel="Students with disabilities - 11"
          gaAction="View subtopic responses"
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
