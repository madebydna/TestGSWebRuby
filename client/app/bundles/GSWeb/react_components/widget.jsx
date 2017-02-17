import React, { PropTypes } from 'react';
import SpinnyWheel from './spinny_wheel';
import { geocode } from '../components/geocoding';
import * as google_maps from '../components/map/google_maps';

export default class Widget extends React.Component {
  constructor(params) {
    super(params);
    this.geocodeAddress = this.geocodeAddress.bind(this);
    this.putFieldInState = this.putFieldInState.bind(this);
    this.getCode = this.getCode.bind(this);

    let defaultIframeWidth = (window.innerWidth ? window.innerWidth - 20 : undefined) || 740;
    if(defaultIframeWidth > 1180) defaultIframeWidth = 1180;

    this.state = {
      googleMapsInitialized: false,
      searchQuery: params.searchQuery || '',
      textColor: '0066B8',
      borderColor: 'FFCC66',
      lat: params.lat || 37.564144,
      lon: params.lon || -122.00418,
      cityName: params.cityName || 'Fremont',
      state: params.state || 'CA',
      normalizedAddress: params.normalizedAddress || 'Fremont, CA 94536',
      width: params.width || defaultIframeWidth,
      height: params.height || 368,
      zoom: 13,
      baseUrl: "http://www.greatschools.org/widget/map"
    };
  }

  componentDidMount() {
    google_maps.init(function() {
      this.setState({
        googleMapsInitialized: true
      });
    }.bind(this));
  }

  getCode() {
    this.setState({
      showIFrameCode: true
    })
  }

  widgetUrl() {
    let params = [
      'searchQuery',
      'textColor',
      'borderColor',
      'lat',
      'lon',
      'cityName',
      'state',
      'normalizedAddress',
      'width',
      'height',
      'zoom'
    ];
    let q = '';
    params.forEach(k => q = GS.uri.Uri.putIntoQueryString(q, k, encodeURIComponent(this.state[k]), true));

    return this.state.baseUrl + q;
  }

  geocodeAddress(e) {
    this.setState({
      geocoding: true
    });
    geocode(e.target.value)
      .then(json => json[0])
      .done(({lat, lon, normalizedAddress} = {}) => {
        if (lat && lon && normalizedAddress) {
          this.setState({
            lat: lat,
            lon: lon,
            normalizedAddress: normalizedAddress,
            geocoding: false
          });
        }
      })
      .fail(() => {
        this.setState({
          geocoding: false
        });
      });
  }

  putFieldInState(field) {
    return e => { if(e.target.value != '') this.setState({[field]: e.target.value}) }
  }

  iFrameCode() {
    return '<iframe className="greatschools" src="' + this.widgetUrl() + '" width="' + this.state.width + '" height="' + this.state.height + '" marginHeight="0" marginWidth="0" frameBorder="0" scrolling="no"></iframe>';
  }

  render() {
    if(this.state.googleMapsInitialized) {
      return this.renderWidget();
    } else {
      return this.renderSpinny();
    }
  }

  renderSpinny() {
    let content = <div style={{height: '300px', width:'100%', display:'block'}}></div>
    return (<div><SpinnyWheel content={content}/></div>);
  }

  renderIframe() {
    return <iframe className="greatschools" src={this.widgetUrl()}
      width={this.state.width} height={this.state.height + 65} marginHeight="0" marginWidth="0" frameBorder="0" scrolling="no">
    </iframe>
  }

  renderWidget() {
    return(
      <div id="widget-form-page" style={{margin: 'auto', maxWidth: '1200px'}}>
        <h1>GreatSchools School Finder Widget</h1>
        <h2>Create Your Customized Widget</h2>
        <hr/>
        <div>
          <form className="widget">
            <div>
              <p>Choose address, zip code or city and state</p>
              <label>Pick the location you'd like your widget to feature </label>
              <input type="text" name="address" onBlur={this.geocodeAddress} defaultValue={this.state.zip} />
            </div>
            <div>
              <p>Choose the width and height of the widget</p>
              <div>
                <label>Width</label>
                <input type="text" name="width" onBlur={this.putFieldInState('width')} defaultValue={this.state.width}/>
              </div>
              <div>
                <label>Height</label>
                <input type="text" name="height" onBlur={this.putFieldInState('height')} defaultValue={this.state.height}/>
              </div>
            </div>
          </form>
        </div>
        <br/><button onClick={this.getCode}>Get Wiget Code</button>

        { this.state.showIFrameCode && 
          <div>
            <br/>
            <p>Cut and paste this code into your site:</p>
            <textarea style={{width: this.state.width, height: '200px'}} value={this.iFrameCode()} readOnly="true" />
          </div>
        }
        <div className="preview">
          <p>Preview your widget</p>
          {this.state.geocoding ? this.renderSpinny() : this.renderIframe() }
        </div>
      </div>
    );
  }
}
