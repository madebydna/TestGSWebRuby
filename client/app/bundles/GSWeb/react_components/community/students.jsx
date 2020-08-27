import React, { useEffect } from "react";
import PropTypes from "prop-types";
import { t } from "util/i18n";
import { generateEthnicityChart } from "../../components/ethnicity_pie_chart";
import { generateSubgroupPieCharts } from "../../components/subgroup_charts";
import InfoBox from '../school_profiles/info_box';

const generateLegend = (ethnicityData, pageType) => {
  const sortedEthnicityData = ethnicityData.sort((a, b) => {
    return b[`${pageType}_value`] - a[`${pageType}_value`]
  })
  return (
    <div>
      {sortedEthnicityData.map((bd, idx) => {
        const value = Math.round(bd[`${pageType}_value`]);
        const displayedValue = value > 0 ? value : '<1';
        const ethnicityColors = ["#0f69c4", "#2bdc99", "#f1830f", "#f1e634", "#6f2eb4", "#ef60d0", "#ca3154", "#999EFF"]
        return (
          <div className="legend-separator js-highlightPieChart clearfix" data-slice-id={idx} key={bd.breakdown}>
            <div className="legend-square" style={{ float: "left", backgroundColor: ethnicityColors[idx] }} />
            <div className="legend-title" style={{ float: 'left' }}>{bd.breakdown}</div>
            <div className="legend-title" style={{ float: 'right' }}>{displayedValue}%</div>
          </div>
        )
      })}
    </div>
  )
}

const Students = ({ ethnicityData, subgroupsData, genderData, translations, sources, pageType }) => {
  useEffect(() => {
    generateEthnicityChart(ethnicityData, pageType)
    generateSubgroupPieCharts({ 'subgroup': subgroupsData, 'gender': genderData }, pageType)
  }, [])

  return (
    <div className="profile-module">
      <div className="module-header">
        <div className="circle-rating--equity-blue">
          <span className="icon-users"/>
        </div>
        <div className="title-container">
          <h3 className="modules-title"
            dangerouslySetInnerHTML={{ __html: translations.title }}
          />
          <div dangerouslySetInnerHTML={{ __html: translations.subtitle }} />
        </div>
      </div>
      <section className="students-module">
        <div className='students-container'>
          <div className='students-demographic-chart'>
            <div id="ethnicity-graph" />
          </div>
          {generateLegend(ethnicityData, pageType)}
        </div>
        <div className="subgroups">
          <div className="row" />
        </div>
        <div className="gender" />
      </section>
      <InfoBox content={sources} element_type="sources" pageType={pageType}>{t('See notes')}</InfoBox>
    </div>
  )
}

Students.propTypes = {
  ethnicityData: PropTypes.array,
  subgroupsData: PropTypes.object,
  genderData: PropTypes.object,
  translations: PropTypes.object,
  sources: PropTypes.string,
  pageType: PropTypes.string
};

Students.defaultProps = {
  ethnicityData: [],
  subgroupsData: {},
  genderData: {}
};

export default props => <Students {...props}/>;