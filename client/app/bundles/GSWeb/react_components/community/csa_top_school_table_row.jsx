import React from "react";
import PropTypes from "prop-types";
import Rating from "../../components/rating";
import ModalTooltip from "../modal_tooltip";
import { SM, validSizes as validViewportSizes } from "util/viewport";
import { t, capitalize } from "util/i18n";
import { getDistrictHref } from 'util/school';

const renderSchoolItem = ({ name, rating, links, districtName, enrollment, gradeLevels, schoolType, csaAwardYears, address, state, community }) => {
  const content = <div dangerouslySetInnerHTML={{ __html: rating ? t("rating_description_html") : t("no_rating_description_html") }} />;
  const districtLink = getDistrictHref(state, address.city, districtName);

  return <React.Fragment>
    <div className="content-container">
      <div>
        <Rating score={rating} size="medium" />
        <div className="scale">
          <ModalTooltip content={content} gaCategory={capitalize(community)}>
            <span className="info-circle icon-info" />
          </ModalTooltip>
        </div>
      </div>
      <div className="school-info">
        <a href={links.collegeSuccess}>
          {name}
        </a>
        {renderCsaYears(csaAwardYears)}
        <p className="students">{capitalize(t(`school_types.${schoolType}`))}, {gradeLevels} | {enrollment} {t("students")}</p>
        {renderDistrictName(districtName, districtLink)}
      </div>
    </div>
    <div className="blue-line" />
  </React.Fragment>;
}

const renderDistrictName = (districtName, districtLink) => {
  if (districtName && districtLink) {
    return (
      <p className="school-district">
        <a href={districtLink}>{districtName}</a>
      </p>
    );
  } else if (districtName) {
    return (
      <p className="school-district">{districtName}</p>
    );
  }
};

const renderCsaYears = (csaAwardYears) => {
  let csaYears = csaAwardYears.join(", ");
  return (
    <div className="top-schools-csa">
      <span>{t('csa_winner')}</span>: {csaYears} 
    </div>
  );
};

const CsaTopSchoolTableRow = (props) => (
  <div className="school-list-item">
    {renderSchoolItem(props)}
  </div>
);


CsaTopSchoolTableRow.propTypes = {
  id: PropTypes.number.isRequired,
  state: PropTypes.string.isRequired,
  name: PropTypes.string.isRequired,
  address: PropTypes.shape({}).isRequired,
  schoolType: PropTypes.oneOf(["public", "private", "charter"]).isRequired,
  gradeLevels: PropTypes.string.isRequired,
  enrollment: PropTypes.number,
  rating: PropTypes.number,
  ratingScale: PropTypes.string,
  districtName: PropTypes.string,
  links: PropTypes.shape({
    collegeSuccess: PropTypes.string.isRequired
  }).isRequired
};

CsaTopSchoolTableRow.defaultProps = {
  enrollment: null,
  rating: null,
  ratingScale: null,
  active: false,
  districtName: null
};

export default CsaTopSchoolTableRow;
