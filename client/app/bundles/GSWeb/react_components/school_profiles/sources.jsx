import React from 'react';
import PropTypes from 'prop-types';
import { t } from 'util/i18n';
import Remodal from 'react_components/remodal';
import InfoBox from 'react_components/school_profiles/info_box';

const Sources = ({sources}) => {
  if (sources.length < 1) return null;

  let sourcesNode = sources.map((sourceObj, i) => {
    if (sourceObj.names.length < 1) return null;
    let sourceLine = sourceObj.names.map((name, j) => {
      let year = sourceObj.years[j];
      if(year) {
        return <span key={j}><span className="emphasis">{ t('source') }:</span> {name}, {year}</span>
      } else {
        return <span key={j}><span className="emphasis">{ t('source') }:</span> {name}</span>
      }
    }).reduce((accum, source) => [accum, ', ', source]);

    return <div key={i}>
      <h4>{sourceObj.heading}</h4>
      <p>{sourceLine}</p>
    </div>
  });

  return <div className="sourcing">
    <h1>{t('profile_data_sources_and_info').replace('&amp;', '&')}</h1>
    {sourcesNode}
  </div>
};

Sources.propTypes = {
  sources: PropTypes.arrayOf(PropTypes.shape({
    heading: PropTypes.string.isRequired,
    subheadings: PropTypes.arrayOf(PropTypes.string),
    description: PropTypes.string,
    names: PropTypes.arrayOf(PropTypes.string).isRequired,
    years: PropTypes.arrayOf(PropTypes.string)
  }))
}

export default Sources;
