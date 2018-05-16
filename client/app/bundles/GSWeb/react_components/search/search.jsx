import React from 'react';
import PropTypes from 'prop-types';
import { addQueryParamToUrl } from 'util/uri';
import SpinnyWheel from '../spinny_wheel';
import SpinnyOverlay from '../spinny_overlay';
import * as googleMaps from '../../components/map/google_maps';
import * as googleMapExtensions from '../../components/map/google_maps_extensions';
import Map from '../../components/map/map';
import { createMarkersFromSchools } from '../../components/map/map_marker';
import Legend from '../../components/map/legend';
import FilterBar from './filter_bar';
import SearchContext from './search_context';
import School from './school';
import SortSelect from './sort_select';
import SearchLayout from './search_layout';
import pageNumbers from 'util/pagination';
import Selectable from 'react_components/selectable';
import AnchorButton from 'react_components/anchor_button';
import ListMapDropdown from './list_map_dropdown';
import { validSizes as validViewportSizes } from 'util/viewport';
import PaginationButtons from './pagination_buttons';

class Search extends React.Component {
  static defaultProps = {
    city: null,
    state: null,
    schools: [],
    loadingSchools: false
  };

  static propTypes = {
    city: PropTypes.string,
    state: PropTypes.string,
    schools: PropTypes.arrayOf(PropTypes.object),
    resultSummary: PropTypes.string.isRequired,
    paginationSummary: PropTypes.string.isRequired,
    address_coordinates: PropTypes.arrayOf(PropTypes.object).isRequired,
    loadingSchools: PropTypes.bool,
    page: PropTypes.number.isRequired,
    totalPages: PropTypes.number.isRequired,
    onPageChanged: PropTypes.func.isRequired,
    size: PropTypes.oneOf(validViewportSizes).isRequired
  };

  constructor(props) {
    super(props);
    this.map = null;
    this.initGoogleMaps = this.initGoogleMaps.bind(this);
    this.showMapView = this.showMapView.bind(this);
    this.showListView = this.showListView.bind(this);
    this.state = {
      googleMapsInitialized: false,
      listHidden: true,
      currentView: 'list'
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

  renderPaginationButtons() {
    const options = [];
    pageNumbers(
      this.props.page,
      this.props.totalPages,
      ({ prev, next, range }) => {
        options.push({
          key: '<',
          value: prev,
          label: '<',
          preventSelect: !prev
        });
        range.forEach(pageNum => {
          options.push({
            key: pageNum,
            value: pageNum,
            label: pageNum
          });
        });
        options.push({
          key: '>',
          value: next,
          label: '>',
          preventSelect: !next
        });
      }
    );

    // href={addQueryParamToUrl('page', value, window.location.href)}
    return (
      <Selectable
        options={options}
        allowDeselect={false}
        activeOptions={options.filter(o => o.value === this.props.page)}
        onSelect={({ value } = {}) => {
          if (value && value !== this.props.page) {
            this.props.onPageChanged(value);
          }
        }}
      >
        {opts =>
          opts.map(({ option, active, select }) => (
            <AnchorButton
              key={option.key}
              enabled={!option.preventSelect}
              active={active}
              onClick={select}
            >
              {option.label}
            </AnchorButton>
          ))
        }
      </Selectable>
    );
  }

  render() {
    return (
      <SearchLayout
        size={this.props.size}
        currentView={this.state.currentView}
        renderHeader={() => (
          <React.Fragment>
            <FilterBar />
          </React.Fragment>
        )}
        renderSubheader={() => (
          <React.Fragment>
            <div>{this.props.resultSummary}</div>
            <SortSelect />
            <ListMapDropdown
              currentView={this.state.currentView}
              onSelect={currentView => {
                this.setState({ currentView });
              }}
            />
          </React.Fragment>
        )}
        renderAd={() => <div className="ad-bar">Advertisement</div>}
        renderList={() => (
          <React.Fragment>
            <SpinnyOverlay spin={this.props.loadingSchools}>
              {({ createContainer, spinny }) =>
                createContainer(
                  <section className="school-list">
                    {spinny}
                    <ol>
                      {this.props.schools.map(s => (
                        <li
                          key={s.state + s.id}
                          className={s.active ? 'active' : ''}
                        >
                          <School {...s} />
                        </li>
                      ))}
                      {this.props.totalPages > 1 && (
                        <li>
                          <div className="pagination-buttons button-group">
                            <PaginationButtons
                              page={this.props.page}
                              totalPages={this.props.totalPages}
                              onPageChanged={this.props.onPageChanged}
                            />
                          </div>
                        </li>
                      )}
                    </ol>
                  </section>
                )
              }
            </SpinnyOverlay>
          </React.Fragment>
        )}
        mapHidden={this.state.mapHidden}
        renderMap={() => (
          <SpinnyOverlay
            spin={
              !this.state.googleMapsInitialized || this.state.loadingSchools
            }
          >
            {({ createContainer, spinny }) =>
              createContainer(
                <div style={{ width: '100%', height: '100%' }}>
                  {spinny}
                  {this.state.googleMapsInitialized && (
                    <Map
                      googleMaps={google.maps}
                      markers={createMarkersFromSchools(
                        this.props.schools,
                        this.props.school,
                        this.map
                      )}
                      changeLocation={() => {}}
                      hidden={this.state.mapHidden}
                      {...this.props}
                    />
                  )}
                  <Legend content={<div>ASSETS/COPY HERE!</div>} />
                </div>
              )
            }
          </SpinnyOverlay>
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
