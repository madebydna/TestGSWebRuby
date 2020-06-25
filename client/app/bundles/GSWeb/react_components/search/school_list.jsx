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

const content =
  <span>
    <span>{t('sponsored_tooltip_blurb')}</span>
    <span> <a href={links.sponsoredSchools} target='_blank'>{t('top_schools.learn_more')}</a></span>
  </span>;

const renderSponsorSearchResultAd = () =>(
  <li className="sponsored-school-result-ad dn">
    <div>
      <span className="sponsor-ad">{t('Sponsored Ad')}</span>
      <span>
        <ModalTooltip content={content}>
          <span className="info-circle icon-info" />
        </ModalTooltip>
      </span>
    </div>
    <Ad slot="greatschools_Search_sponsoredlisting" />
  </li>
);

const SchoolList = ({
  schools,
  saveSchoolCallback,
  isLoading,
  pagination,
  toggleHighlight,
  size,
  shouldRemoveAds
}) => {
  let indexOfNonAssignedSchools = 0;
  const hasAssignedSchools = schools.some(s=>s.assigned)
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
          if (s.assigned === null) { indexOfNonAssignedSchools++; }
          const shouldRenderSponsorSchoolAdOnMobileWithAssignedSchools = hasAssignedSchools && indexOfNonAssignedSchools === 1 && size <= SM && schools.length >= 8;
          const shouldRenderSponsorSchoolAdOnMobile = !hasAssignedSchools && indexOfNonAssignedSchools === 2 && size <= SM && schools.length >= 8;
          const shouldRenderSponsorSchoolAdOnDesktop = indexOfNonAssignedSchools === 3 && size > SM && schools.length >= 8;
          return(
            <React.Fragment key={s.state + s.id + (s.assigned ? 'assigned' : '')}>
              {!shouldRemoveAds && index > 0 &&
                index % 4 === 0 && index < 24 && (
                  <Ad
                    slot={`greatschools_Search_after${index}_300x250`}
                    slotOccurrenceNumber={index / 4}
                    key={`ad-${index}`}
                    container={<li className="ad" />}
                  />
                )}
              {/* To place the faux ad after a certain amount of non-assigned school search result   */}
              {shouldRenderSponsorSchoolAdOnMobile && renderSponsorSearchResultAd()}
              {shouldRenderSponsorSchoolAdOnMobileWithAssignedSchools && renderSponsorSearchResultAd()}
              {shouldRenderSponsorSchoolAdOnDesktop && renderSponsorSearchResultAd()}
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
        {!shouldRemoveAds && (schools.length < 5 && schools.length > 0) && (
          <Ad
            slot={`greatschools_Search_after4_300x250`}
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
  const unsaved = s.savedSchool ? "" : " unsaved";
  return active + assigned + unsaved;
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
