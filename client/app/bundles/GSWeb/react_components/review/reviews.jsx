import React, { PropTypes } from 'react';
import ReviewsList from './reviews_list';
import ReviewForm from './form/review_form';
import { t } from '../../util/i18n';
import { isSignedIn, getSchoolUserDigest } from '../../util/session';
import { size as viewportSize } from 'util/viewport';
import { scrollToElement } from 'util/scrolling';
import { fetchReviews } from '../../api_clients/reviews';

export default class Reviews extends React.Component {

  static propTypes = {
    reviews: React.PropTypes.arrayOf(React.PropTypes.shape({
      five_star_review: React.PropTypes.object,
      user_review_digest: React.PropTypes.string,
      topical_reviews: React.PropTypes.array,
      most_recent_date: React.PropTypes.string,
      user_type_label: React.PropTypes.string,
      avatar: React.PropTypes.number,
      reviewSubmitMessage: React.PropTypes.object
    })),
    state: React.PropTypes.string,
    schoolId: React.PropTypes.number,
    questions: React.PropTypes.arrayOf(React.PropTypes.object)
  };

  constructor(props) {
    super(props);
    var currentUserReportedMap = {};
    this.REVIEW_CHUNK_SIZE = 5;
    // TODO: This needs to be hooked up somewhere. Maybe from props?
    this.state = {
      reviewSubmitMessage: {},
      reviews: this.initializeReviewsList(),
      offset: 0,
      limit: this.startingLimit()
    };
    this.handleCloseAllClick = this.handleCloseAllClick.bind(this);
    this.handleClick = this.handleClick.bind(this);
    this.renderReviewLayout = this.renderReviewLayout.bind(this);
    this.handleReviewSubmitMessage = this.handleReviewSubmitMessage.bind(this);
    this.renderReviewForm = this.renderReviewForm.bind(this);
    this.reorderForCurrentUser = this.reorderForCurrentUser.bind(this);
    this.renderReviewsList = this.renderReviewsList.bind(this);
    this.handleUpdateOfReviews = this.handleUpdateOfReviews.bind(this);
  }

  componentWillMount() {
    this.reorderForCurrentUserIfSignedIn();
  }

  initializeReviewsList() {
    return JSON.parse(JSON.stringify(this.props.reviews));
  }

  renderReviewsList() {
    return(<ReviewsList
      reviews = { this.state.reviews }
      reviewSubmitMessage = { this.state.reviewSubmitMessage }
      limit = { this.state.limit }
      offset = { this.state.offset }
    />);
  }

  reorderForCurrentUserIfSignedIn() {
    if (isSignedIn()) {
      getSchoolUserDigest().done(this.reorderForCurrentUser)
    }
  }

  reorderForCurrentUser(xhr) {
      let schoolUserDigest = xhr.school_user_digest;
      let reviews = JSON.parse(JSON.stringify(this.state.reviews));
      let userReview = this.findRemoveUserReview(schoolUserDigest, reviews);
      if (userReview) {
        reviews.unshift(userReview);
      }
      this.setState( { reviews: reviews });
  }

  // TODO: refactor reorder For CurrentUser and HandleUpdateOfReviews to remove
  // duplication

  handleUpdateOfReviews(userReviews) {
    let newUserReviews = userReviews;
    let reviews = JSON.parse(JSON.stringify(this.state.reviews));
    let schoolUserDigest = newUserReviews.school_user_digest
    let existingUserReviews = this.findRemoveUserReview(schoolUserDigest, reviews);
    reviews.unshift(newUserReviews);
    this.setState( { reviews: reviews });
  }

  findRemoveUserReview(schoolUserDigest, reviews) {
    var result;
    for(var i = 0; i < reviews.length; i++) {
      if ( reviews[i].school_user_digest == schoolUserDigest ) {
        result = reviews.splice(i,1)[0];
        break;
      }
    }
    return result;
  }

  handleReviewSubmitMessage(messageObject) {
    this.setState({ reviewSubmitMessage: messageObject });
  }

  renderReviewForm() {
    return(<ReviewForm
      state = { this.props.state }
      schoolId = { this.props.schoolId }
      questions = { this.props.questions }
      handleReviewSubmitMessage = { this.handleReviewSubmitMessage }
      handleUpdateOfReviews = { this.handleUpdateOfReviews }
    />);
  }

  renderReviewLayout(componentFunction, title) {
    return(
      <div id="Reviews">
        <div className="rating-container profile-section">
          <div className="row">
            <div className="col-xs-12 col-lg-3">
              <div className="section-title">
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

  //returns a boolean
  isLastPage(){
    return this.props.reviews_list_count <= this.state.limit;
  }

  startingLimit() {
    let limit = this.REVIEW_CHUNK_SIZE;
    if(viewportSize() == 'xs') {
      limit = 2;
    }

    if(limit > this.props.reviews.length) limit = this.props.reviews.length;
    return limit;
  }

  nextLimit() {
    let limit = this.state.limit + this.REVIEW_CHUNK_SIZE;
    if(limit > this.props.reviews_list_length) limit = this.props_reviews_list_length;
    return limit;
  }

  handleClick() {
    if(this.state.reviews.length < this.props.reviews_list_count) {
      fetchReviews(this.props.state, this.props.schoolId).done((reviews) => this.setState({reviews: reviews}));
    }
    this.setState({limit: this.nextLimit()});
  }

  handleCloseAllClick() {
    this.setState({limit: this.startingLimit()});
    scrollToElement('.review-summary');
  }

  showMoreButton(){
    if(!this.isLastPage()) {
      return (<div className="show-more__button" onClick={this.handleClick}>
        {t('Show more')}
      </div>);
    }
  }

  closeAllButton(){
    if(this.state.limit > this.startingLimit()) {
      return (<div className="tac ptm"><a onClick={this.handleCloseAllClick}>
        {t('Close all')}
      </a></div>);
    }
  }

  render() {
    let reviewFormContent = null;
    let recentComments = null;
    if(this.state.reviews.length > 0) {
      reviewFormContent = this.renderReviewLayout(this.renderReviewForm, t('Review this school'));
      recentComments = this.renderReviewLayout(this.renderReviewsList, t('Recent Comments'));
    } else {
      reviewFormContent = this.renderReviewLayout(this.renderReviewForm, t('Be the first to review this school'));
    }
    return (
      <div>
        <a className="anchor-mobile-offset" name="Reviews"></a>
        { reviewFormContent }
        { recentComments }
        {this.showMoreButton()}
        {this.closeAllButton()}
      </div>
    );
  }
}
