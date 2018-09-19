import React from "react";
import PropTypes from "prop-types";
import { t } from "util/i18n";
import ModalTooltip from "../modal_tooltip";
import InfoBox from '../school_profiles/info_box';
import LoadingOverlay from "../search/loading_overlay";

class Mobility extends React.Component {
  static propTypes = {
    locality: PropTypes.obj
  };

  static defaultProps = {
    locality: {}
  };

  constructor(props){
    super(props);
    this.state={
      isLoading: true,
      didFail: false,
      data: {},
      error: ""
    }
    this.handleErrors = this.handleErrors.bind(this);
    this.renderAgencies = this.renderAgencies.bind(this);
    this.renderTransportation = this.renderTransportation.bind(this);
  }

  componentDidMount(){
    $.ajax({
      type: 'GET',
      url: `https://mobilityscore.transitscreen.io/api/v1/locations.json?coordinates=${this.props.locality.lat},${this.props.locality.lon}&key=7Q0jpitnctkvjAkfl`,
    }).done($jsonRes => this.setState({
        isLoading: false,
        data: $jsonRes.data.mobilityScore,
      }))
      .fail(error => this.setState({
        isLoading: false,
        didFail: true,
        error: error.textStatus
      }))
  }

  renderAgencies = (agencies) =>(
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

  renderTransportation(str, transportation){
    return(
      <React.Fragment>
        <div className="transportation-container">
          <img src={`https://mobilityscore.transitscreen.io/${transportation.logo}`} alt={str} />
          <p>{transportation.friendlyName}</p>
        </div>
        {this.renderAgencies(transportation.agencies)}
      </React.Fragment>
    )
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
    }else{
      const { mapURL,
              badgeURL, 
              scoreLabel, 
              scoreDescription, 
              score, modes } = this.state.data;
      const content = 
        <div className="tooltip-content">
          <p>{t('mobility.help')}</p>
          <a href={mapURL} rel="nofollow" target="_blank">
            {t('top_schools.learn_more')}
          </a>
        </div>
      const sources = t('mobility.sources_html');
      return(
        <React.Fragment>
          <section className="mobility-module">
            <div>
              <div>
                <img src={badgeURL} alt="badge_score"/>
                <div className="scale">
                  <ModalTooltip content={content}>
                    <span className="info-circle icon-info" />
                  </ModalTooltip>
                </div>
              </div>
              <div className="transportation-content">
                <h3>{scoreLabel}</h3>
                <p>{scoreDescription}</p>
                {score !== 0 ? <div className="blue-line"/> : null}
                {modes.subway ? this.renderTransportation("subway", modes.subway) : null}
                {modes.bus ? this.renderTransportation("bus", modes.bus) : null}
                {modes.carshare ? this.renderTransportation("carshare", modes.carshare) : null}
                {modes.bikeshare ? this.renderTransportation("bikeshare", modes.bikeshare) : null}
                {modes.scootershare ? this.renderTransportation("scootershare", modes.scootershare) : null}
                {modes.ridehailing ? this.renderTransportation("ridehailing", modes.ridehailing) : null}
              </div>
            </div>
          </section>
          <InfoBox content={sources} element_type="sources" >{t('See notes')}</InfoBox>
        </React.Fragment>
      )
    }
  }
}

export default Mobility;