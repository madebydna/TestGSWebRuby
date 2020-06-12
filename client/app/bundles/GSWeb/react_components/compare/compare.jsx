
import React from 'react';
import PropTypes from 'prop-types';
import { Provider } from 'react-redux';
import { getStore } from 'store/appStore';
import CompareLayout from './compare_layout';
import CompareContext from './compare_context';
import SearchBox from 'react_components/search_box'
import NoCompareSchoolListResult from './no_compare_school_list_result';
import NoResults from 'react_components/search/no_results';
import Ad from 'react_components/ad';
import { init as initAdvertising } from 'util/advertising';
import { XS, validSizes as validViewportSizes } from 'util/viewport';
import withViewportSize from 'react_components/with_viewport_size';
import SortSelect from 'react_components/search/sort_select';
import BreakdownSelect from './breakdown_select';
import CompareSchoolTable from './compare_school_table';
import { find as findSchools } from 'api_clients/schools';
import { t } from 'util/i18n';
import { analyticsEvent } from 'util/page_analytics';
import remove from 'util/array';
import DistanceFilter from 'react_components/search/distance_filter';
import DistanceContext from 'react_components/search/distance_context';

class Compare extends React.Component {
  static defaultProps = {
  };

  static propTypes = {
    size: PropTypes.oneOf(validViewportSizes).isRequired
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

  noCompareResults() {
    return this.props.schools.length < 2 ? (
      <NoCompareSchoolListResult />
    ) : null;
  }

  noResults(){
    return this.props.schools.length === 0 && <NoResults/>
  }

  render() {
    const pinnedSchool = this.props.schools.filter(s => s.pinned)[0];
    if(this.noResults()){
      return <NoResults />
    }else{
      return (
        <DistanceContext.Consumer>
        {({ distance, onChange }) => (
        <CompareLayout
          searchBox={<SearchBox size={this.props.size} />}
          pinnedSchool={pinnedSchool}
          size={this.props.size}
          sortSelect={<SortSelect
            includeDistance={this.props.shouldIncludeDistance}
            includeRelevance={this.props.shouldIncludeRelevance}
            additionalOptions={
              [{
                key: 'testscores',
                label: t('test_scores.title')
              }]
            }
          />}
          breakdownSelect={<BreakdownSelect
            breakdowns={pinnedSchool.ethnicityBreakdowns}
          />
          }
          distanceFilter={ <DistanceFilter distance={distance} onChange={onChange} /> }
          schoolTable={
            <CompareSchoolTable
              schools={this.props.schools}
              isLoading={this.props.loadingSchools}
              compareTableHeaders={this.props.compareTableHeaders}
            />
          }
          noCompareResults={this.noCompareResults()}
        >
        </CompareLayout>
        )}</DistanceContext.Consumer>
      );
    }

    }
}

export { Compare };
export default function() {
  return (
    <Provider store={getStore()}>
      <CompareContext.Provider>
        <CompareContext.Consumer>
          {state => <Compare {...state} />}
        </CompareContext.Consumer>
      </CompareContext.Provider>
    </Provider>
  );
}
