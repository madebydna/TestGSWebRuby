import React from 'react';
import PropTypes from 'prop-types';
import SearchContext from './search_context';
import DistanceConsumer from './distance_context';
import SortSelect from './sort_select';
import SearchLayout from './search_layout';
import ListMapDropdown from './list_map_dropdown';
import PaginationButtons from './pagination_buttons';
import Map from './map';
import SchoolList from './school_list';
import EntityTypeDropdown from './entity_type_dropdown';
import GradeLevelButtons from './grade_level_buttons';
import GradeLevelCheckboxes from './grade_level_checkboxes';
import DistanceFilter from './distance_filter';
import DistanceContext from './distance_context';
import Ad from 'react_components/ad';
import { init as initAdvertising } from 'util/advertising';
import { XS, validSizes as validViewportSizes } from 'util/viewport';

class Search extends React.Component {
  static defaultProps = {
    city: null,
    state: null,
    lat: null,
    lon: null,
    schools: [],
    loadingSchools: false,
    shouldIncludeDistance: false
  };

  static propTypes = {
    city: PropTypes.string,
    state: PropTypes.string,
    schools: PropTypes.arrayOf(PropTypes.object),
    resultSummary: PropTypes.string.isRequired,
    defaultLat: PropTypes.number.isRequired,
    defaultLon: PropTypes.number.isRequired,
    lat: PropTypes.number,
    lon: PropTypes.number,
    loadingSchools: PropTypes.bool,
    page: PropTypes.number.isRequired,
    totalPages: PropTypes.number.isRequired,
    onPageChanged: PropTypes.func.isRequired,
    size: PropTypes.oneOf(validViewportSizes).isRequired,
    shouldIncludeDistance: PropTypes.bool,
    toggleHighlight: PropTypes.func
  };

  constructor(props) {
    super(props);
    this.state = {
      currentView: 'map'
    };
  }

  componentDidMount() {
    initAdvertising();
  }

  render() {
    return (
      <DistanceContext.Consumer>
        {({ distance, onChange }) => (
          <SearchLayout
            size={this.props.size}
            currentView={this.state.currentView}
            entityTypeDropdown={<EntityTypeDropdown />}
            gradeLevelButtons={<GradeLevelButtons />}
            gradeLevelCheckboxes={<GradeLevelCheckboxes />}
            distanceFilter={
              distance ||
              (this.props.schools[0] &&
                this.props.schools[0].distance !== undefined) ? (
                  <DistanceFilter distance={distance} onChange={onChange} />
              ) : null
            }
            sortSelect={
              <SortSelect includeDistance={this.props.shouldIncludeDistance} />
            }
            resultSummary={this.props.resultSummary}
            listMapDropdown={
              <ListMapDropdown
                currentView={this.state.currentView}
                onSelect={currentView => {
                  this.setState({ currentView });
                }}
              />
            }
            tallAd={
              <div className="ad-bar">
                <Ad slot="Search_160x600" dimensions={[160, 600]} />
              </div>
            }
            schoolList={
              <SchoolList
                toggleHighlight={this.props.toggleHighlight}
                schools={this.props.schools}
                isLoading={this.props.loadingSchools}
              />
            }
            pagination={
              this.props.totalPages > 1 ? (
                <div className="pagination-container">
                  <div className="pagination-buttons button-group">
                    <PaginationButtons
                      page={this.props.page}
                      totalPages={this.props.totalPages}
                      onPageChanged={this.props.onPageChanged}
                      mobileView={this.props.size === XS}
                    />
                  </div>
                </div>
              ) : null
            }
            map={
              <Map
                lat={this.props.lat || this.props.defaultLat}
                lon={this.props.lon || this.props.defaultLon}
                schools={this.props.schools}
                isLoading={this.props.loadingSchools}
              />
            }
          />
        )}
      </DistanceContext.Consumer>
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
