import React from 'react';
import PropTypes from 'prop-types';
import { validSizes as validViewportSizes } from 'util/viewport';
import SpinnyOverlay from '../spinny_overlay';
import FilterBar from './filter_bar';
import SearchContext from './search_context';
import School from './school';
import SortSelect from './sort_select';
import SearchLayout from './search_layout';
import ListMapDropdown from './list_map_dropdown';
import PaginationButtons from './pagination_buttons';
import Map from './map';

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
        renderMap={() => (
          <Map
            school={this.props.school}
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
