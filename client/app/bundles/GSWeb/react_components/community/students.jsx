import React, { useEffect } from "react";
import PropTypes from "prop-types";
import { generateEthnicityChart } from "../../components/ethnicity_pie_chart";
import { generateSubgroupPieCharts } from "../../components/subgroup_charts";
import InfoBox from '../school_profiles/info_box';
import { t } from "util/i18n";

const generateLegend = (ethnicityData) => {
  const sortedEthnicityData = ethnicityData.sort((a, b) => {
    return b.district_value - a.district_value
  })
  return (
    <div>
      {sortedEthnicityData.map((bd, idx) => {
        const value = Math.round(bd.district_value);
        const displayedValue = value > 0 ? value : '<1';
        const ethnicityColors = ["#0f69c4", "#2bdc99", "#f1830f", "#f1e634", "#6f2eb4", "#ef60d0", "#ca3154", "#999EFF"]
        return (
          <div className="legend-separator js-highlightPieChart clearfix" data-slice-id={idx}>
            <div className="legend-square" style={{ float: "left", backgroundColor: ethnicityColors[idx] }}></div>
            <div className="legend-title" style={{ float: 'left' }}>{bd.breakdown}</div>
            <div className="legend-title" style={{ float: 'right' }}>{displayedValue}%</div>
          </div>
        )
      })}
    </div>
  )
}

const Students = ({ ethnicityData, subgroupsData, genderData, translations, sources }) => {
  useEffect(() => {
    generateEthnicityChart(ethnicityData, 'district')
    generateSubgroupPieCharts({ 'subgroup': subgroupsData, 'gender': genderData }, 'district')
  }, [])

  return (
    <React.Fragment>
      <div className="module-header">
        <div className="circle-rating--equity-blue">
          <span className="icon-users"></span>
        </div>
        <div className="title-container">
          <h2 className="modules-title"
            dangerouslySetInnerHTML={{ __html: translations.title }}
          />
          <span dangerouslySetInnerHTML={{ __html: translations.subtitle }} />
        </div>
      </div>
      <section className="students-module">
        <div className='students-container'>
          <div className='students-demographic-chart'>
            <div id="ethnicity-graph"></div>
          </div>
          {generateLegend(ethnicityData)}
        </div>
        <div className="subgroups">
          <div className="row">
          </div>
        </div>
        <div className="gender"> </div>
      </section>
      <InfoBox content={sources} element_type="sources" >{t('See notes')}</InfoBox>
    </React.Fragment>
  )
}

Students.propTypes = {
  ethnicityData: PropTypes.array,
  subgroupsData: PropTypes.obj,
  genderData: PropTypes.obj,
  translations: PropTypes.obj,
  sources: PropTypes.string
};

Students.defaultProps = {
  ethnicityData: [],
  subgroupsData: {},
  genderData: {}
};

export default Students;