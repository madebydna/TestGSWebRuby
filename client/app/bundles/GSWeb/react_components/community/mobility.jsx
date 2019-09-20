import React from "react";
import PropTypes from "prop-types";
import { t } from "util/i18n";
import ModalTooltip from "../modal_tooltip";
import {findMobilityScoreWithLatLon as fetchMobilityScore} from 'api_clients/mobility';
import InfoBox from '../school_profiles/info_box';
import LoadingOverlay from "../search/loading_overlay";
import { analyticsEvent } from "util/page_analytics";
import { cloneDeep } from 'lodash';

class Mobility extends React.Component {
  static propTypes = {
    locality: PropTypes.object,
    pageType: PropTypes.string.isRequired
  };

  static defaultProps = {
    locality: {},
    pageType: ""
  };

  constructor(props){
    super(props);
    this.state={
      isLoading: true,
      didFail: false,
      data: {},
      error: ""
    }
    this.renderAgencies = this.renderAgencies.bind(this);
    this.renderTransportation = this.renderTransportation.bind(this);
    this.handleGoogleAnalyics = this.handleGoogleAnalyics.bind(this);
  }

  componentDidMount(){
    fetchMobilityScore(this.props.locality.mobilityURL, this.props.locality.lat, this.props.locality.lon)
      .done($jsonRes => this.setState({
        isLoading: false,
        data: $jsonRes.data.mobilityScore,
      }))
      .fail(error => this.setState({
        isLoading: false,
        didFail: true,
        error: error
      }))
  }

  renderAgencies = (agencies) => (
    agencies.map(agency => {
      const logoLine = agency.agencyColor !== null ? `solid 5px ${agency.agencyColor}` : "solid 5px #dbe6eb";
      return(
        <div key={`${agency.agencyShortName}`} className="agencies">
          <div style={{height: '25px', borderRight: logoLine}}></div>
          <img src={`https://mobilityscore.transitscreen.io/${agency.agencyLogoLight}`} alt={agency.agencyShortName}/>
          <p>{agency.agencyShortName}</p>
        </div>
      )
    }
  ));

  convertAgenciesStructure(agencies) {
    const clonedAgencies = cloneDeep(agencies);
    return clonedAgencies.reduce( (accum, el) => {
      const agenciesLogos = accum.map(a => a.agencyLogoLight);
      if (!agenciesLogos.includes(el.agencyLogoLight)){
        accum.push(el);
      }else{
        const idx = agenciesLogos.indexOf(el.agencyLogoLight);
        accum[idx].agencyShortName = `${accum[idx].agencyShortName}, ${el.agencyShortName}`;
      }
      return accum;
    }, [])
  }



  renderTransportation(str, transportation){
    return(
      <React.Fragment key={`frag-${str}`}>
        <div className="transportation-container">
          <img src={`https://mobilityscore.transitscreen.io/${transportation.logo}`} alt={str} />
          <p>{transportation.friendlyName}</p>
        </div>
        {this.renderAgencies(this.convertAgenciesStructure(transportation.agencies))}
      </React.Fragment>
    )
  }

  handleGoogleAnalyics(action, label){
    analyticsEvent(`${this.props.pageType}`, action, label);
  }

  render(){
    if (this.state.isLoading === true) {
      return(
        <section className="mobility-module">
          <div className="null-state">
            <h3>Loading...</h3>
            <LoadingOverlay numItems={4} />
          </div>
        </section>
      )
    }else if(this.state.didFail === true){
      return(
        <section className="mobility-module">
          <div className="null-state">
            <h4>There was an issue loading the module. Sorry for the inconvenience. Please try again.</h4>
          </div>
        </section>
      )
    }else if(this.state.data.score === 0){
      const noScoreMapping = { 'City': t('mobility.no_score_city'), 'District': t('mobility.no_score_district') }
      return(
        <section className="mobility-module">
          <div className="null-state">
            <h4>{noScoreMapping[this.props.pageType]}</h4>
          </div>
        </section>
      )
    }else{
      const { mapURL,
              badgeURL, 
              scoreLabel, 
              scoreDescription, 
              score, 
              modes } = this.state.data;
      const content = 
        <div className="tooltip-content">
          <p>{t('mobility.help')}</p>
          <a href={mapURL} rel="nofollow" target="_blank" onClick={() => this.handleGoogleAnalyics('Infobox', 'Mobility')}>
            {t('top_schools.learn_more')}
          </a>
        </div>
      const sources = t('mobility.sources_html');
      const transportationsMethods = Object.keys(modes);
      const renderTransportationArray = [];
      transportationsMethods.forEach(vehicle=>{
        const properties = modes[`${vehicle}`]
        renderTransportationArray.push(this.renderTransportation(vehicle, properties));
      });
      return(
        <React.Fragment>
          <section className="mobility-module">
            <div>
              {/* <div key="foo">
                Removing for now until TransitScreen has better coverage
                <ModalTooltip content={content}>
                  <img src={badgeURL} alt="badge_score" onMouseEnter={() => this.handleGoogleAnalyics('Infobox', 'Mobility')} />
                  <div className="scale" onMouseEnter={() => this.handleGoogleAnalyics('Infobox', 'Mobility')}>
                    <span className="info-circle icon-info" />
                  </div>
                </ModalTooltip>
              </div> */}
              <div className="transportation-content">
                <h3>{t('mobility.transportation_narration')}</h3>
                {/* <h3>{scoreLabel}</h3>
                <p>{scoreDescription}</p> */}
                {score !== 0 ? <div className="blue-line"/> : null}
                <div>
                  <a href={mapURL} rel="nofollow" target="_blank" onClick={() => this.handleGoogleAnalyics('External link', 'Mobility transport') }>
                    {renderTransportationArray}
                  </a>
                </div>
              </div>
            </div>
          </section>
          <InfoBox content={sources} element_type="sources" pageType={this.props.pageType}>{t('See notes')}</InfoBox>
        </React.Fragment>
      )
    }
  }
}

export default Mobility;