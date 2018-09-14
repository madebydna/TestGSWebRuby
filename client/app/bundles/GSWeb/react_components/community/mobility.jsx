import React from "react";
import PropTypes from "prop-types";
import { t } from "util/i18n";

class Mobility extends React.Component {
  constructor(props){
    super(props);
    this.state={
      isLoading: true,
      data: {}
    }
  }

  componentDidMount(){
    fetch(`https://mobilityscore.transitscreen.io/api/v1/locations.json?coordinates=${this.props.locality.lat},${this.props.locality.lon}&key=7Q0jpitnctkvjAkf`)
      .then(response => response.json())
      .then(data => this.setState({
        isLoading: false,
        data
      }))
  }

  render(){
    if (this.state.isLoading === true) {
      return(
        <div>Module is loading</div>
      )
    }else{
      const data = this.state.data.data.mobilityScore;
      return(
        <section>
          <img src={data.badgeUrl} alt="badge_score"/>
        </section>
      )
    }
  }
}

export default Mobility;