
import React from 'react';
import PropTypes from 'prop-types';
import { getStore } from 'store/appStore';
import Breadcrumbs from 'react_components/breadcrumbs';
import CompareLayout from './compare_layout';
import SearchBox from 'react_components/search_box'
import Ad from 'react_components/ad';
import { init as initAdvertising } from 'util/advertising';
import { XS, validSizes as validViewportSizes } from 'util/viewport';
import withViewportSize from 'react_components/with_viewport_size';
import Select from 'react_components/select';
import CompareQueryParams from './compare_query_params';
import CompareSchoolTable from './compare_school_table';
import '../../vendor/remodal';
import { find as findSchools } from 'api_clients/schools';
import { analyticsEvent } from 'util/page_analytics';
import remove from 'util/array';

class Compare extends React.Component {
  static defaultProps = {
  };

  static propTypes = {
    viewportSize: PropTypes.oneOf(validViewportSizes).isRequired,
  };

  constructor(props) {
    super(props);
  }

  componentDidMount() {
    initAdvertising();
  }

  // 62 = nav offset on non-mobile
  scrollToTop = () =>
    this.state.size > XS
      ? document.querySelector('#compare-schools').scrollIntoView()
      : window.scroll(0, 0);

  updateSchools() {
    this.setState(
      {
        loadingSchools: true
      },
      () => {
        const start = Date.now();
        this.findSchoolsWithReactState().done(
          ({ items: schools, totalPages, paginationSummary, resultSummary }) =>
            setTimeout(
              () =>
                this.setState({
                  schools,
                  totalPages,
                  paginationSummary,
                  resultSummary,
                  loadingSchools: false
                }),
              500 - (Date.now() - start)
            )
        );
      }
    );
  }

  // school finder methods, based on obj state

  findTopRatedSchoolsWithReactState(newState = {}) {
    return findSchools(
      Object.assign(
        {
          city: this.props.city,
          state: this.props.state,
          levelCodes: this.props.levelCodes,
          extras: ['students_per_teacher', 'review_summary']
        },
        newState
      )
    );
  }

  render() {
    return (
      <CompareQueryParams>
        {paramProps => console.log(paramProps) ||
          <CompareLayout
            searchBox={<SearchBox size={this.props.viewportSize} />}
            // Dummy Select for Now
            sortSelect={<Select
              objects={["Test Score", "Ratings"]}
              labelFunc={d => d}
              keyFunc={d => d}
              onChange={d => updateTableView(d.key)}
              defaultLabel={
                "Test Score"
              }
              defaultValue={"Test Score"}
            />}
            schoolTable={
              <CompareSchoolTable
                toggleHighlight={this.props.toggleHighlight}
                schools={this.props.schools}
                isLoading={this.props.loadingSchools}
                searchTableViewHeaders={this.props.searchTableViewHeaders}
                tableView={this.props.tableView}
              />
            }
          >
          </CompareLayout>
        }
      </CompareQueryParams>
    );
  }
}

const CompareWithViewportSize = withViewportSize('size')(Compare);

export default CompareWithViewportSize;
