import React from 'react';
import PropTypes from 'prop-types';
import ReviewsList from 'react_components/review/reviews_list';
import { t } from 'util/i18n';
import { XS, size as viewportSize } from 'util/viewport';
import { scrollToElement } from 'util/scrolling';

class RecentReviews extends React.Component {
  static propTypes = {
    reviews: PropTypes.arrayOf(
      PropTypes.shape({
        five_star_review: PropTypes.object,
        user_review_digest: PropTypes.string,
        topical_reviews: PropTypes.array,
        most_recent_date: PropTypes.string,
        user_type_label: PropTypes.string,
        avatar: PropTypes.number,
        reviewSubmitMessage: PropTypes.object
      })
    ),
    state: PropTypes.string,
    schoolId: PropTypes.number,
    questions: PropTypes.arrayOf(PropTypes.object)
  };

  constructor(props) {
    super(props);
    this.renderReviewsList = this.renderReviewsList.bind(this);
    this.renderReviewLayout = this.renderReviewLayout.bind(this);
  }

  renderReviewsList() {
    return (
      <ReviewsList
        reviews={this.props.reviews}
        reviewSubmitMessage={"PLACEHOLDER"}
        limit={3}
        offset={0}
      />
    );
  }

  renderReviewLayout(componentFunction) {
    return (
      <div id="Reviews">
        <div className="rating-container community-section">
          <div className="row">
            <div className="col-xs-12 col-lg-12">{componentFunction()}</div>
          </div>
        </div>
      </div>
    );
  }

  render(){
    const recentComments = this.renderReviewLayout(
      this.renderReviewsList
    );
    return(
      <div>
        <a className="anchor-mobile-offset" name="Reviews" />
        {recentComments}
      </div>
    )
  }
}

export default RecentReviews;