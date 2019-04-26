import React from 'react';
import PropTypes from 'prop-types';
import ReviewsList from 'react_components/review/reviews_list';
import Button from "../button";
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
        reviewSubmitMessage: PropTypes.object,
        school_name: PropTypes.string
      })
    ),
    community: PropTypes.string.isRequired
  };

  static defaultProps = {
    reviews: [],
    community: ""
  };

  constructor(props) {
    super(props);
    this.renderReviewsList = this.renderReviewsList.bind(this);
    this.renderReviewLayout = this.renderReviewLayout.bind(this);
  }

  renderAddReviewsBlurb() {
    if (this.props.community === "city") {
      return <p>{t('recent_reviews.city_blurb')}</p>;
    } else if (this.props.community === "district") {
      return <p>{t('recent_reviews.district_blurb')}</p>;
    } else {
      return;
    }
  }

  renderReviewsList() {
    return (
      <ReviewsList
        reviews={this.props.reviews}
        reviewSubmitMessage={"PLACEHOLDER"}
        limit={3}
        offset={0}
        pageType={"Community"}
      />
    );
  }

  renderReviewLayout(componentFunction) {
    return (
      <React.Fragment>
        {/* Commented out until we need to filter for gradeLevels */}
        {/* <div className="grade-filter">
          <span className="button-group">
            <Button label={t("All")} active={true} />
            <Button label={t("Elementary")} active={false} />
            <Button label={t("Middle")} active={false} />
            <Button label={t("High")} active={false} />
          </span>
        </div> */}
        <div className="row">
          <div className="col-xs-12 col-lg-12">{componentFunction()}</div>
        </div>
        {this.props.community !== "state" && 
          <React.Fragment>
            <div className="blue-line" />
            <div className="add-review-container">
              {this.renderAddReviewsBlurb()}
              <a href="/reviews/">
                <button>{t('recent_reviews.Add a review')}</button>
              </a>
            </div>
          </React.Fragment>
        }
      </React.Fragment>
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