import React from 'react';
import PropTypes from 'prop-types';
import { validSizes as validViewportSizes } from 'util/viewport';
import FilterBar from './filter_bar';
import SearchContext from './search_context';
import School from './school';
import SortSelect from './sort_select';
import SearchLayout from './search_layout';
import ListMapDropdown from './list_map_dropdown';
import PaginationButtons from './pagination_buttons';
import Map from './map';
import SchoolList from './school_list';

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
        renderHeader={() => (
          <React.Fragment>
            <FilterBar includeDistance={this.props.shouldIncludeDistance} />
          </React.Fragment>
        )}
        renderSubheader={() => (
          <React.Fragment>
            <div>{this.props.resultSummary}</div>
            <span>Sort by </span>
            <SortSelect includeDistance={this.props.shouldIncludeDistance} />
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
          <SchoolList
            schools={this.props.schools}
            isLoading={this.props.loadingSchools}
            pagination={
              this.props.totalPages > 1 ? (
                <PaginationButtons
                  page={this.props.page}
                  totalPages={this.props.totalPages}
                  onPageChanged={this.props.onPageChanged}
                />
              ) : null
            }
          />
        )}
        renderMap={() => (
          <Map
            schools={this.props.schools}
            isLoading={this.props.loadingSchools}
          />
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
