import React from 'react';
import { renderToStaticMarkup } from 'react-dom/server';
import { capitalize, t } from 'util/i18n';
import unratedSchoolIcon from 'school_profiles/brown-owl.svg';
import {
  getHomesForSaleHref,
  studentsPhrase,
  schoolTypePhrase
} from 'util/school';

export default function createInfoWindow(entity, campaignCode) {
  const homesForSaleHref = getHomesForSaleHref(entity.state, entity.address, campaignCode);

  const schoolLevels = entity => {
    const levelNameMap = {
      p: 'Preschool',
      e: 'Elementary',
      m: 'Middle',
      h: 'High'
    };
    return Object.entries(entity.schoolCountsByLevelCode).map(
      ([level, value]) => [levelNameMap[level], value]
    );
  };

  const levelMarkup = entity => {
    return schoolLevels(entity)
      .map(([level, value]) => (<span key={`${level}-${value}`}>{level} ({value})</span>))
      .reduce((list, current) => [list, ', ', current]);
  }

  const ratingDiv = entity => {
    const visibleRating = entity.rating != 'NR' ? entity.rating : undefined;
    let ratingText = <span />;
    let ratingScale = '';

    if (visibleRating) {
      ratingText = (
        <div>
          {visibleRating}
          <span>/10</span>
        </div>
      );
      if (entity.ratingScale) {
        const scaleString = entity.ratingScale
          .split(' ')
          .reduce((list, current) => [list, <br />, current]);
        ratingScale = <div className="rating-scale">{scaleString}</div>;
      }
    } else {
      return (
        <div className="rating-container">
          <img src={unratedSchoolIcon} alt="" />
          <div className="rating-scale">{t('Currently unrated')}</div>
          {entity.savedSchoolCallback && <div
            data-state={entity.state}
            data-id={entity.id}
            className={entity.savedSchool ? 'icon-heart js-info-heart' : 'icon-heart-outline js-info-heart'}
          />}
        </div>
      );
    }
    let shape = 'circle';
    if (entity.type == 'school' && entity.schoolType == 'private') {
      shape = 'diamond';
    } else if (entity.type == 'district') {
      shape = 'square';
    }
    if (entity.type == 'school') {
      return (
        <div className="rating-container">
          <div
            className={`rating_${entity.rating} ${shape}-rating--small rating`}
          >
            {ratingText}
          </div>
          {ratingScale}
          {/* Saved School heart container that only appears during SchoolSearchResult */}
          {entity.savedSchoolCallback && <div
            data-state={entity.state}
            data-id={entity.id}
            className={entity.savedSchool ? 'icon-heart js-info-heart' : 'icon-heart-outline js-info-heart'}
          />}
        </div>
      );
    }
    return <div />;
  };

  const addressString = `${entity.address.street1}, ${entity.address.city}, ${
    entity.state
  } ${entity.address.zip}`;
  const contentString = (
    <div className="info-window">
      {entity.assigned && (
        <div className="assigned-text">{t('assigned_school')}</div>
      )}
      <div className="clearfix">
        {ratingDiv(entity)}
        <div className="school-info">
          <a href={entity.links ? entity.links.profile : '#'}>
            {entity.name}
          </a>
          {entity.type == 'school' &&
            entity.address && (
              <div>
                <div className="address">{addressString}</div>
                <div className="school-subinfo">
                  {schoolTypePhrase(entity.schoolType, entity.gradeLevels)}
                  {entity.enrollment !== 0 && (
                    <span>
                      <span className="divider"> | </span>
                      <span>{studentsPhrase(entity.enrollment)}</span>
                    </span>
                  )}
                </div>
                {homesForSaleHref && (
                  <div className="other-links">
                    <span className="icon-house" />
                    <a href={homesForSaleHref} rel="nofollow" target="_blank">
                      {' '}
                      {t('homes_for_sale')}
                    </a>
                  </div>
                )}
              </div>
            )}
          {entity.schoolCountsByLevelCode && (
            <div>
              <br />Number of schools:<div>{levelMarkup(entity)}</div>
            </div>
          )}
        </div>
      </div>
    </div>
  );
  return renderToStaticMarkup(contentString);
}
