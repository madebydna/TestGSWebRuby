import React from 'react';
import ReactDOMServer from 'react-dom/server';
import InfoBox from '../../school_profiles/info_box';
import { t } from '../../../util/i18n';

function Sources ({ sources }) {

  const renderSources = () => {
    return (
      <div className="sourcing">
        <h1>{t('district_data_sources_and_info')}</h1>
        {sources.map((source, i)=>{
          return(
            <div key={`dist_source_${i}`}>
              <h4>{source.name}</h4>
              <p>{source.description}</p>
              <p>{source.source_and_year}</p>
            </div>
          )
        })}
      </div>
    )
  }

  const _sources = ReactDOMServer.renderToStaticMarkup(renderSources());
  return (
    <InfoBox content={_sources} element_type="sources" className='sources-link'>{ t('See notes') }</InfoBox>
  );
}

export default Sources;
