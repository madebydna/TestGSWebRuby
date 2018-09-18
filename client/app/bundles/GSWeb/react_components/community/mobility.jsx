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
      data: {}
    }
    this.handleErrors = this.handleErrors.bind(this);
    this.renderAgencies = this.renderAgencies.bind(this);
    this.renderTransportation = this.renderTransportation.bind(this);
  }

  componentDidMount(){
    fetch(`https://mobilityscore.transitscreen.io/api/v1/locations.json?coordinates=${this.props.locality.lat},${this.props.locality.lon}&key=7Q0jpitnctkvjAkf`)
      .then(this.handleErrors)
      .then(response => response.json())
      .catch(error => this.setState({
        didFail: true,
        error
      }))
      .then(data => this.setState({
        isLoading: false,
        data
      })
      .catch(error => this.setState({
        didFail: true,
        error
      }))
    );
  }

  handleErrors(res){
    if (!res.ok) {
      return Promise.reject('Error occurred');
    }
    return res;
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

  renderTransportation(str, data){
    return(
      <React.Fragment>
        <div className="transportation-container">
          <img src={`https://mobilityscore.transitscreen.io/${data.logo}`} alt={str} />
          <p>{data.friendlyName}</p>
        </div>
        {this.renderAgencies(data.agencies)}
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
      const data = this.state.data.data.mobilityScore;
      const content = 
        <div className="tooltip-content">
          <p>{t('mobility.help')}</p>
          <a href={data.mapURL} rel="nofollow" target="_blank">
            {t('top_schools.learn_more')}
          </a>
        </div>
      const sources = t('mobility.sources_html');
      return(
        <React.Fragment>
          <section className="mobility-module">
            <div>
              <div>
                <img src={data.badgeURL} alt="badge_score"/>
                <div className="scale">
                  <ModalTooltip content={content}>
                    <span className="info-circle icon-info" />
                  </ModalTooltip>
                </div>
              </div>
              <div className="transportation-content">
                <h3>{data.scoreLabel}</h3>
                <p>{data.scoreDescription}</p>
                {data.score !== 0 ? <div className="blue-line"/> : null}
                {data.modes.subway ? this.renderTransportation("subway", data.modes.subway) : null}
                {data.modes.bus ? this.renderTransportation("bus", data.modes.bus) : null}
                {data.modes.carshare ? this.renderTransportation("carshare", data.modes.carshare) : null}
                {data.modes.bikeshare ? this.renderTransportation("bikeshare", data.modes.bikeshare) : null}
                {data.modes.scootershare ? this.renderTransportation("scootershare", data.modes.scootershare) : null}
                {data.modes.ridehailing ? this.renderTransportation("ridehailing", data.modes.ridehailing) : null}
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