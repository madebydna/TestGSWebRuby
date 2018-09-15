import React from "react";
import PropTypes from "prop-types";
import { t } from "util/i18n";
import ModalTooltip from "../modal_tooltip";

class Mobility extends React.Component {
  constructor(props){
    super(props);
    this.state={
      isLoading: true,
      data: {}
    }
    this.renderAgencies = this.renderAgencies.bind(this);
    this.renderTransportation = this.renderTransportation.bind(this);
  }

  componentDidMount(){
    fetch(`https://mobilityscore.transitscreen.io/api/v1/locations.json?coordinates=${this.props.locality.lat},${this.props.locality.lon}&key=7Q0jpitnctkvjAkf`)
      .then(response => response.json())
      .then(data => this.setState({
        isLoading: false,
        data
      }))
  }

  renderAgencies = (agencies) =>(
    agencies.map(agency => {
      const logoLine = `solid 5px ${agency.agencyColor}`;
      console.log(logoLine)
      return(
        <div className="agencies">
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
        <div>Module is loading</div>
      )
    }else{
      const data = this.state.data.data.mobilityScore;
      const content = "Hello"
      return(
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
              <div className="blue-line"/>
              {data.modes.subway ? this.renderTransportation("subway", data.modes.subway) : null}
              {data.modes.bus ? this.renderTransportation("bus", data.modes.bus) : null}
              {data.modes.carshare ? this.renderTransportation("carshare", data.modes.carshare) : null}
              {data.modes.bikeshare ? this.renderTransportation("bikeshare", data.modes.bikeshare) : null}
              {data.modes.scootershare ? this.renderTransportation("scootershare", data.modes.scootershare) : null}
              {data.modes.ridehailing ? this.renderTransportation("ridehailing", data.modes.ridehailing) : null}
            </div>
          </div>
        </section>
      )
    }
  }
}

export default Mobility;