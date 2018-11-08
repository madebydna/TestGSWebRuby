import React from "react";
import PropTypes from "prop-types";
import Ad from "react_components/ad";
import School from "./school";
import LoadingOverlay from "./loading_overlay";
import { SM } from "util/viewport";
import { t, capitalize } from '../../util/i18n';
import ModalTooltip from "../modal_tooltip";
import { links } from 'components/links'; 
import { checkSponsorSearchResult } from '../../util/advertising';

const SchoolList = ({
  schools,
  saveSchoolCallback,
  isLoading,
  pagination,
  toggleHighlight,
  size
}) => {
  let numsNonAssignedSchools = 0;
  checkSponsorSearchResult();
  return(
    <section className="school-list">
      {
        /* would prefer to just not render overlay if not showing it,
        but then loader gif has delay, and we would need to preload it */
        <LoadingOverlay
          visible={isLoading && schools.length > 0}
          numItems={schools.length}
        />
      }
      <ol className={isLoading ? "loading" : ""}>
        {schools.map((s, index) => {
          if (s.assigned === null) { numsNonAssignedSchools++; }
          const content = 
            <span>
              <span>{t('sponsored_tooltip_blurb')}</span>
              <span> <a href={links.sponsored_schools} target='_blank'>{t('top_schools.learn_more')}</a></span>
            </span>
          const shouldRenderSponsorSchoolAdOnMobile = size <= SM && schools.length >= 8 && numsNonAssignedSchools === 6;
          const shouldRenderSponsorSchoolAdOnDesktop = size > SM && schools.length >= 8 && numsNonAssignedSchools === 4;
          const sponsorSearchResultAd =
            <li className="sponsored-school-result-ad dn">
              <div>
                <span>{t('Sponsored Ad')}</span>
                <span>
                  <ModalTooltip content={content}>
                    <span className="info-circle icon-info" />
                  </ModalTooltip>
                </span>
              </div>
              <Ad slot="search_sponsoredlisting" sizeName="search_result_item" />
            </li>;
          return(
            <React.Fragment key={s.state + s.id + (s.assigned ? 'assigned' : '')}>
              {index > 0 &&
                index % 4 === 0 && (
                  <Ad
                    slot={`Search_After${index}_300x250`}
                    sizeName="box"
                    slotOccurrenceNumber={index / 4}
                    key={`ad-${index}`}
                    container={<li className="ad" />}
                  />
                )}
              {/* To place the faux ad after a certain amount of non-assigned school search result   */}
              {shouldRenderSponsorSchoolAdOnMobile && sponsorSearchResultAd}
              {shouldRenderSponsorSchoolAdOnDesktop && sponsorSearchResultAd}
              {size > SM ? (
                <li
                  key={'li' + s.state + s.id + (s.assigned ? 'assigned' : '')}
                  onMouseEnter={() => toggleHighlight(s)}
                  onMouseLeave={() => toggleHighlight(s)}
                  onTouchStart={() => toggleHighlight(s)}
                  className={classNameGenerator(s)}
                >
                  <School {...s} saveSchoolCallback={saveSchoolCallback} />
                </li>
              ) : (
                <li
                  key={'li' + s.state + s.id + (s.assigned ? 'assigned' : '')}
                  onMouseEnter={() => toggleHighlight(s)}
                  onMouseLeave={() => toggleHighlight(s)}
                  className={classNameGenerator(s)}
                >
                  <School {...s} saveSchoolCallback={saveSchoolCallback} />
                </li>
              )}
            </React.Fragment>
          )
        }
        )}
        {(schools.length < 5 && schools.length > 0) && (
          <Ad
            slot={`Search_After4_300x250`}
            sizeName="box"
            slotOccurrenceNumber={1}
            key={`ad-${schools.length + 1}`}
            container={<li className="ad" />}
          />
        )}
        {pagination && <li>{pagination}</li>}
      </ol>
    </section>
  )
};

const classNameGenerator = function (s) {
  const active = s.active ? "active" : "";
  const assigned = s.assigned ? " assigned" : "";
  return active + assigned;
};

SchoolList.propTypes = {
  schools: PropTypes.arrayOf(PropTypes.shape(School.propTypes)).isRequired,
  isLoading: PropTypes.bool,
  pagination: PropTypes.element,
  toggleHighlight: PropTypes.func.isRequired
};
SchoolList.defaultProps = {
  isLoading: false,
  pagination: null
};
export default SchoolList;
