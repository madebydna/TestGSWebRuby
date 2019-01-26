import React from 'react';
import PropTypes from 'prop-types';
import { Provider } from 'react-redux';
import { getStore } from 'store/appStore';
import Breadcrumbs from 'react_components/breadcrumbs';
import SearchContext from './search_context';
import SortSelect from './sort_select';
import SearchLayout from './search_layout';
import MySchoolListLayout from './my_school_list_layout';
import ListMapTableSelect from './list_map_table_select';
import PaginationButtons from './pagination_buttons';
import Map from './map';
import SchoolList from './school_list';
import SchoolTable from './school_table';
import EntityTypeDropdown from './entity_type_dropdown';
import GradeLevelButtons from './grade_level_buttons';
import ChooseTableButtons from './choose_table_buttons';
import StateSelectDropdown from './state_select_dropdown';
import DistanceFilter from './distance_filter';
import DistanceContext from './distance_context';
import Ad from 'react_components/ad';
import { init as initAdvertising } from 'util/advertising';
import { XS, validSizes as validViewportSizes } from 'util/viewport';
import SearchBox from '../search_box';
import NoResults from './no_results';

class Search extends React.Component {
  static defaultProps = {
    lat: null,
    lon: null,
    schools: [],
    loadingSchools: false,
    shouldIncludeDistance: false,
    autoSuggestQuery: () => {},
    breadcrumbs: [],
    q: null,
    layout: 'Search',
    schoolKeys: [],
    schoolMarkers: []
  };

  static propTypes = {
    schools: PropTypes.arrayOf(PropTypes.object),
    schoolMarkers: PropTypes.arrayOf(PropTypes.object),
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
    toggleHighlight: PropTypes.func.isRequired,
    refreshAdOnScroll: PropTypes.func.isRequired,
    breadcrumbs: PropTypes.arrayOf(
      PropTypes.shape({
        text: PropTypes.string.isRequired,
        url: PropTypes.string.isRequired
      })
    ),
    autoSuggestQuery: PropTypes.func,
    view: PropTypes.string.isRequired,
    updateView: PropTypes.func.isRequired,
    q: PropTypes.string,
    searchTableViewHeaders: PropTypes.object,
    layout: PropTypes.string,
    schoolKeys: PropTypes.arrayOf(PropTypes.arrayOf(PropTypes.array)),
  };

  constructor(props){
    super(props);
    this.setMapDisplayState = this.setMapDisplayState.bind(this);
    this.state = { shouldDisplayFullMarkers: false}
  }

  componentDidMount() {
    initAdvertising();
  }

  noResults() {
    return this.props.schools.length === 0 ? (
      <NoResults resultSummary={this.props.resultSummary} />
    ) : null;
  }

  setMapDisplayState(boolean){
    this.setState({ shouldDisplayFullMarkers: boolean})
  }

  getSchoolsDetails(){
    const schools = this.props.schools;
    let schoolMarkers = this.props.schoolMarkers;
    schools.forEach(s=>{
      const idTag = s.state.toLowerCase() + s.id;
      schoolMarkers[idTag] = { ...schoolMarkers[idTag],...s};
    })
    return Object.values(schoolMarkers);
  }

  render() {
    const Layout = {
      Search: SearchLayout,
      MySchoolList: MySchoolListLayout
    }[this.props.layout];
    return (
      <DistanceContext.Consumer>
        {({ distance, onChange }) => (
          <Layout
            size={this.props.size}
            view={this.props.view}
            entityTypeDropdown={<EntityTypeDropdown />}
            gradeLevelButtons={<GradeLevelButtons />}
            chooseTableButtons={<ChooseTableButtons />}
            stateSelect={<StateSelectDropdown />}
            distanceFilter={
              distance ||
              (this.props.schools[0] &&
                this.props.schools[0].distance !== undefined) ? (
                  <DistanceFilter distance={distance} onChange={onChange} />
              ) : null
            }
            sortSelect={
              <SortSelect
                includeDistance={this.props.shouldIncludeDistance}
                includeRelevance={this.props.shouldIncludeRelevance}
              />
            }
            resultSummary={this.props.resultSummary}
            listMapTableSelect={
              <ListMapTableSelect
                view={this.props.view}
                onSelect={this.props.updateView}
                size={this.props.size}
              />
            }
            tallAd={
              <div className="ad-bar">
                <Ad
                  key={`Search_160x600${this.props.page}`}
                  slot="Search_160x600"
                  dimensions={[160, 600]}
                />
              </div>
            }
            numOfSchools={this.props.schools.length}
            schoolList={
              <SchoolList
                toggleHighlight={this.props.toggleHighlight}
                schools={this.props.schools}
                saveSchoolCallback={this.props.saveSchoolCallback}
                isLoading={this.props.loadingSchools}
                size={this.props.size}
              />
            }
            schoolTable={
              <SchoolTable
                toggleHighlight={this.props.toggleHighlight}
                schools={this.props.schools}
                isLoading={this.props.loadingSchools}
                searchTableViewHeaders={this.props.searchTableViewHeaders}
                tableView={this.props.tableView}
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
                locationMarker={
                  this.props.lat && this.props.lon
                    ? { lat: this.props.lat, lon: this.props.lon }
                    : null
                }
                schools={this.getSchoolsDetails()}
                isLoading={this.props.loadingSchools}
                locationLabel={this.props.locationLabel}
                setMapDisplayState={this.setMapDisplayState}
              />
            }
            searchBox={<SearchBox size={this.props.size} />}
            breadcrumbs={<Breadcrumbs items={this.props.breadcrumbs} />}
            noResults={this.noResults()}
            refreshAdOnScroll={this.props.refreshAdOnScroll}
          />
        )}
      </DistanceContext.Consumer>
    );
  }
}

export { Search };
export default function() {
  return (
    <Provider store={getStore()}>
      <SearchContext.Provider layout={'Search'}>
        <SearchContext.Consumer>
          {state => <Search {...state} />}
        </SearchContext.Consumer>
      </SearchContext.Provider>
    </Provider>
  );
}
