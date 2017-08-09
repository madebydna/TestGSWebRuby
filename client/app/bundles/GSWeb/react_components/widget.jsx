import React, { PropTypes } from 'react';
import SpinnyWheel from './spinny_wheel';
import { geocode } from '../components/geocoding';
import * as google_maps from '../components/map/google_maps';
import { logWidgetCodeRequest } from '../api_clients/widget_logs';
import ValidatingInput from './validating_input';
import * as validations from '../components/validations';
import { putIntoQueryString } from '../util/uri';

export default class Widget extends React.Component {
  constructor(params) {
    super(params);
    this.geocodeAddress = this.geocodeAddress.bind(this);
    this.putFieldInState = this.putFieldInState.bind(this);
    this.getCode = this.getCode.bind(this);

    let defaultIframeWidth = (window.innerWidth ? window.innerWidth - 20 : undefined) || 740;
    if(defaultIframeWidth > 1180) defaultIframeWidth = 1180;

    let widgetHost = 'www.greatschools.org';
    if(/greatschools\.org(:\d+)?$/.test(window.location.host)) {
      widgetHost = window.location.host;
    }

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
      baseUrl: "//" + widgetHost + "/widget/map"
    };
  }

  componentDidMount() {
    google_maps.init(function() {
      this.setState({
        googleMapsInitialized: true
      });
    }.bind(this));
  }

  getCodeButtonEnabled() {
    return (this.state.targetUrlValid && this.state.emailValid && this.state.termsValid);
  }

  getCode() {
    logWidgetCodeRequest(this.state.email, this.state.targetUrl).always(() => {
      this.setState({
        showIFrameCode: true
      })
    });
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
    params.forEach(k => q = putIntoQueryString(q, k, encodeURIComponent(this.state[k]), true));

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
    return e => { if(e.target.value != '') this.setState({[field]: e.target.value, showIFrameCode: false})}
  }

  iFrameCode() {
    let code = '<iframe className="greatschools" src="' + this.widgetUrl() + '" width="' + this.state.width + '" height="' + this.state.height + '" marginHeight="0" marginWidth="0" frameBorder="0" scrolling="no"></iframe>';
    code = code + '<script type="text/javascript">';
    code = code + 'var _gsreq = new XMLHttpRequest();'
    code = code + 'var _gsid = new Date().getTime();';
    code = code + '_gsreq.open("GET", "https://www.google-analytics.com/collect?v=1&tid=UA-54676320-1&cid="+_gsid+"&t=event&ec=widget&ea=loaded&el="+window.location.hostname+"&cs=widget&cm=web&cn=widget&cm1=1&ni=1");';
    code = code + '_gsreq.send();'
    code = code + '</script>';
    return code;
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
      <div id="widget-form-page" style={{margin: 'auto', maxWidth: '1200px', padding: '0 20px'}}>
        <h1>GreatSchools School Finder Widget</h1>
        <h2>Create your customized widget</h2>
        <hr/>
        <div>
          <form className="widget">
            <div>
              <p>Pick the location you'd like your widget to feature</p>
              <label>Choose address, zip code, or city and state</label>
              <input type="text" name="address" onBlur={this.geocodeAddress} defaultValue={this.state.zip}/>
            </div>
            <div>
              <p>Choose the size of your widget</p>
              <div>
                <label>Width</label>
                <input type="text" name="width" onBlur={this.putFieldInState('width')} defaultValue={this.state.width}/>
              </div>
              <div>
                <label>Height</label>
                <input type="text" name="height" onBlur={this.putFieldInState('height')} defaultValue={this.state.height}/>
              </div>
            </div>
            <div>
              <p>Please enter your email address</p>
              <div>
                <label>Email</label>
                <ValidatingInput type="email" name="email"
                  onBlur={this.putFieldInState('email')}
                  defaultValue={this.state.email}
                  validation={validations.VALID_EMAIL_REQUIRED}
                  onInvalid={() => this.setState({emailValid: false})}
                  onValid={() => this.setState({emailValid: true})}
                />
              </div>
            </div>
            <div>
              <p>Enter the website URL where this widget will be hosted</p>
              <div>
                <label>Your website URL</label>
                <ValidatingInput type="url"
                  name="targetUrl"
                  onBlur={this.putFieldInState('targetUrl')}
                  defaultValue={this.state.targetUrl}
                  validation={validations.VALID_URL_REQUIRED}
                  onInvalid={() => this.setState({targetUrlValid: false})}
                  onValid={() => this.setState({targetUrlValid: true})}
                />
              </div>
            </div>
            <div>
              <label htmlFor="termsCheckbox">I agree to the widget <a href="/gk/licensing/greatschools-widget-terms-use/" target="_blank">terms of service</a>.</label>
              <ValidatingInput type="checkbox"
                               id="termsCheckbox"
                               onBlur={this.putFieldInState('terms')}
                               name="terms"
                               validation={validations.TERMS_REQUIRED}
                               onInvalid={() => this.setState({termsValid: false})}
                               onValid={() => this.setState({termsValid: true})}
                               />
            </div>
          </form>
        </div>
        <br/><button onClick={this.getCode} disabled={!this.getCodeButtonEnabled()}>Get Widget Code</button>

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
