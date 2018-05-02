import React from 'react';
import PropTypes from 'prop-types';
import SpinnyWheel from '../spinny_wheel';
import SpinnyOverlay from '../spinny_overlay';
import * as googleMaps from '../../components/map/google_maps';
import * as googleMapExtensions from '../../components/map/google_maps_extensions';
import Map from '../../components/map/map';
import createMarkerFactory, {
  createMarkersFromSchools
} from '../../components/map/map_marker';
import Legend from '../../components/map/legend';
import FilterBar from './filter_bar';
import SearchContext from './search_context';
import School from './school';
import SortSelect from './sort_select';
import SearchLayout from './search_layout';

class Search extends React.Component {
  static defaultProps = {
    city: null,
    state: null,
    schools: [],
    loadingSchools: false,
    changeLocation: () => {}
  };

  static propTypes = {
    city: PropTypes.string,
    state: PropTypes.string,
    schools: PropTypes.arrayOf(PropTypes.object),
    result_summary: PropTypes.string.isRequired,
    pagination_summary: PropTypes.string.isRequired,
    address_coordinates: PropTypes.arrayOf(PropTypes.object).isRequired,
    loadingSchools: PropTypes.bool,
    changeLocation: PropTypes.func
  };

  constructor(props) {
    super(props);
    this.map = null;
    this.initGoogleMaps = this.initGoogleMaps.bind(this);
    this.showMapView = this.showMapView.bind(this);
    this.showListView = this.showListView.bind(this);
    this.state = {
      googleMapsInitialized: false,
      listHidden: true
    };
    this.initGoogleMaps();
  }

  initGoogleMaps() {
    googleMaps.init(() => {
      googleMapExtensions.init();
      this.setState({
        googleMapsInitialized: true
      });
    });
  }

  showMapView() {
    this.setState({
      mapHidden: false,
      listHidden: true
    });
  }

  showListView() {
    this.setState({
      mapHidden: true,
      listHidden: false
    });
  }

  render() {
    return (
      <SearchLayout
        renderHeader={() => (
          <React.Fragment>
            <FilterBar />
            <SortSelect />
            <h3>
              <div>{this.props.result_summary}</div>
              <div>{this.props.pagination_summary}</div>
            </h3>
            <div className="right-rail">
              <div className="ad-bar">Advertisement</div>
            </div>
          </React.Fragment>
        )}
        renderRightRail={() => <div className="ad-bar">Advertisement</div>}
        renderList={() => (
          <SpinnyOverlay spin={this.props.loadingSchools}>
            {({ createContainer, spinny }) =>
              createContainer(
                <section className="school-list">
                  {spinny}
                  <ol>
                    {this.props.schools.map(s => (
                      <li className={s.active ? 'active' : ''}>
                        <School {...s} />
                      </li>
                    ))}
                  </ol>
                </section>
              )
            }
          </SpinnyOverlay>
        )}
        renderMap={() => (
          <div className={this.state.mapHidden ? 'map closed' : 'map'}>
            <SpinnyWheel active={!this.state.googleMapsInitialized}>
              {this.state.googleMapsInitialized && (
                <Map
                  googleMaps={google.maps}
                  markers={createMarkersFromSchools(
                    this.props.schools,
                    this.props.school,
                    this.map
                  )}
                  changeLocation={this.props.changeLocation}
                  hidden={this.state.mapHidden}
                  {...this.props}
                />
              )}
              {!this.state.googleMapsInitialized && (
                <div
                  style={{ height: '400px', width: '75%', display: 'block' }}
                />
              )}
              <Legend content={<div>ASSETS/COPY HERE!</div>} />
            </SpinnyWheel>
          </div>
        )}
      />
    );
  }
}

export default function() {
  return (
    <SearchContext.Provider>
      <SearchContext.Consumer>
        {state => <Search {...state} />}
      </SearchContext.Consumer>
    </SearchContext.Provider>
  );
}
