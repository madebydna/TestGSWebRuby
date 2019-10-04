import React from 'react';
import ReactDOMServer from 'react-dom/server';
import InfoBox from '../../school_profiles/info_box';
import { t } from '../../../util/i18n';

class Sources extends React.Component {

  renderSources() {
    return (
      <div className="sourcing">
        <h1>{t('district_data_sources_and_info')}</h1>
        {this.props.sources.map((source, i)=>{
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

  render() {
    const sources = ReactDOMServer.renderToStaticMarkup(this.renderSources());
    return <InfoBox content={sources} element_type="sources" className='sources-link'>{ t('See notes') }</InfoBox>
  }
}

export default Sources;
