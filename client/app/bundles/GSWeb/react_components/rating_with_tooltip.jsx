import React from "react";
import PropTypes from "prop-types";
import { t } from 'util/i18n';
import ModalTooltip from 'react_components/modal_tooltip';
import BrownOwl from './icons/brown_owl';

const RatingWithTooltip = ({rating, ratingScale}) => {
  const className = `circle-rating--small circle-rating--${rating || 'gray'}`;
  const content = (
      <div
          dangerouslySetInnerHTML={{
            __html: rating
                ? t('rating_description_html')
                : t('no_rating_description_html')
          }}
      />
  );
  return (
      <ModalTooltip content={content}>
        <React.Fragment>
          {rating ?
              <div className={className}>
                {rating}
                {rating && <span className="rating-circle-small">/10</span>}
              </div> : <BrownOwl />}
          <div className="scale">
            {ratingScale || t('Currently unrated')}
            <span className="info-circle icon-info" />
          </div>
        </React.Fragment>
      </ModalTooltip>
  );
};

RatingWithTooltip.propTypes = {
  rating: PropTypes.number,
  ratingScale: PropTypes.string
};

export default RatingWithTooltip;