import React from 'react';
import ReviewDistribution from './review_distribution';
import { getAnswerCountsForQuestion } from 'api_clients/reviews';
import { withCurrentSchool }  from 'store/appStore';
import ModalTooltip from 'react_components/modal_tooltip';

export default class ConnectedReviewDistributionModal extends React.Component {

  static propTypes = {
    questionId: React.PropTypes.number,
    question: React.PropTypes.string.isRequired
  };

  constructor(props) {
    super(props);
    this.state = {};
  }

  componentDidMount() {
    withCurrentSchool((state, schoolId) => {
      getAnswerCountsForQuestion(state, schoolId, this.props.questionId)
        .done(distribution => this.setState({distribution: distribution}));
    });
  }

  reviewDistribution() {
    return <div>
      <ReviewDistribution
      distribution={{dist: this.state.distribution, question: this.props.question}}
      />
      <br/><a href="#Reviews" style={{textAlign: 'center'}}>View comments</a>
    </div>
  }

  numberOfResponses() {
    return Object.values(this.state.distribution).reduce((sum, value) => sum + value);
  }

  render() {
    if(this.state.distribution && Object.keys(this.state.distribution).length > 0 && this.props.question) {
      return <ModalTooltip gaLabel="Community feedback - review summary" content={this.reviewDistribution()}>
        <a href="javascript:void(0)">View responses ({this.numberOfResponses()})</a>
      </ModalTooltip>
    }
    return null;
  }
}
