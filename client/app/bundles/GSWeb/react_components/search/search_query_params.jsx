import React from 'react';
import PropTypes from 'prop-types';
import * as queryParams from './query_params';
import createHistory from 'history/createBrowserHistory';

const history = createHistory();
export const pushQueryString = qs => {
  history.push({
    search: qs
  });
};

export default class SearchQueryParams extends React.Component {
  static propTypes = {
    children: PropTypes.func.isRequired
  };

  componentDidMount() {
    history.listen(() => {
      this.forceUpdate();
    });
  }

  render() {
    const extraProps = {
      levelCodes: queryParams.getGradeLevels(),
      entityTypes: queryParams.getEntityTypes(),
      lat: queryParams.getLat(),
      lon: queryParams.getLon(),
      distance: queryParams.getDistance(),
      state: queryParams.getState(),
      id: queryParams.getId(),
      breakdownParam: queryParams.getBreakdown(),
      locationLabel:
      queryParams.getValueForKey('locationLabel') ||
      queryParams.getValueForKey('locationSearchString'),
      sort: queryParams.getSort() || (queryParams.getQ() ? 'relevance' : 'rating'),
      page: queryParams.getPage(),
      q: queryParams.getQ(),
      view: queryParams.getView(),
      tableView: queryParams.getTableView(),
      csaYears: queryParams.getCsaYears(),
      zipcode: queryParams.getZipcode(),
      updateLevelCodes: codes => {
        pushQueryString(queryParams.queryStringWithNewGradeLevels(codes));
      },
      updateEntityTypes: types => {
        pushQueryString(queryParams.queryStringWithNewEntityTypes(types));
      },
      updateSort: sort => {
        pushQueryString(queryParams.queryStringWithNewSort(sort));
      },
      updatePage: (page) => {
        event.preventDefault()
        pushQueryString(queryParams.queryStringWithNewPage(page));
      },
      updateDistance: distance => {
        pushQueryString(queryParams.queryStringWithNewDistance(distance));
      },
      updateView: view => {
        pushQueryString(queryParams.queryStringWithNewView(view));
      },
      updateTableView: tableView => {
        pushQueryString(queryParams.queryStringWithNewTableView(tableView));
      },
      updateBreakdown: breakdown => {
        pushQueryString(queryParams.queryStringWithNewBreakdown(breakdown));
      },
      updateCsaYears: years => {
        pushQueryString(queryParams.queryStringWithNewCsaYears(years));
      }
    };

    return this.props.children(extraProps);
  }
}
