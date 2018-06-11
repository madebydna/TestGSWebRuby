import React from 'react';
import PropTypes from 'prop-types';
import { validSizes as validViewportSizes } from 'util/viewport';
import SearchContext from './search_context';
import SortSelect from './sort_select';
import SearchLayout from './search_layout';
import ListMapDropdown from './list_map_dropdown';
import PaginationButtons from './pagination_buttons';
import Map from './map';
import SchoolList from './school_list';
import EntityTypeButtons from './entity_type_buttons';
import EntityTypeCheckboxes from './entity_type_checkboxes';
import GradeLevelButtons from './grade_level_buttons';
import GradeLevelCheckboxes from './grade_level_checkboxes';
import DistanceFilter from './distance_filter';
import DistanceContext from './distance_context';
import { viewport, XS, validSizes } from 'util/viewport';

class Search extends React.Component {
  static defaultProps = {
    city: null,
    state: null,
    schools: [],
    loadingSchools: false,
    shouldIncludeDistance: false
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
    size: PropTypes.oneOf(validViewportSizes).isRequired,
    shouldIncludeDistance: PropTypes.bool
  };

  constructor(props) {
    super(props);
    this.state = {
      currentView: 'list'
    };
  }

  render() {
    return (
      <SearchLayout
        size={this.props.size}
        currentView={this.state.currentView}
        entityTypeButtons={<EntityTypeButtons />}
        entityTypeCheckboxes={<EntityTypeCheckboxes />}
        gradeLevelButtons={<GradeLevelButtons />}
        gradeLevelCheckboxes={<GradeLevelCheckboxes />}
        distanceFilter={
          <DistanceContext.Consumer>
            {({ distance, onChange }) => (
              <DistanceFilter distance={distance} onChange={onChange} />
            )}
          </DistanceContext.Consumer>
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
        tallAd={() => <div className="ad-bar">Advertisement</div>}
        schoolList={
          <SchoolList
            schools={this.props.schools}
            isLoading={this.props.loadingSchools}
            pagination={
              this.props.totalPages > 1 ? (

                <PaginationButtons
                  page={this.props.page}
                  totalPages={this.props.totalPages}
                  onPageChanged={this.props.onPageChanged}
                  mobileView={this.props.size == XS}
                />
              ) : null
            }
          />
        }
        map={
          <Map
            schools={this.props.schools}
            isLoading={this.props.loadingSchools}
          />
        }
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
