import React from 'react';
import PropTypes from 'prop-types';
import AnchorButton from 'react_components/anchor_button';
import communityAvatar from 'icons/community-avatar.png';

const ShareYourFeedbackCollegeReadiness = ({questionText, buttonClicked, buttonText}) => {
  return (
    <div className="share-your-feedback-cta" style={{paddingTop: '20px'}}>
      <p className="parent-tip">
        <img src={communityAvatar} />
        <span className="speech-bubble left">{questionText}</span>
      </p>
      <div className="actions">
        <AnchorButton href="javascript:void(0)"
                      onClick={buttonClicked}
                      style={{display: 'inline-block'}}
                      className="clearfix js-subtopicAnswerButton">{buttonText}
        </AnchorButton>
      </div>
    </div>
  );
};

ShareYourFeedbackCollegeReadiness.PropTypes = {
  questionText: PropTypes.string.isRequired,
  buttonClicked: PropTypes.func.isRequired,
  buttonText: PropTypes.string
}

export default ShareYourFeedbackCollegeReadiness;
