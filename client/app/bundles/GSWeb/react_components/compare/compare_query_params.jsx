import React from 'react';
import PropTypes from 'prop-types';
import * as queryParams from '../search/query_params';
import createHistory from 'history/createBrowserHistory';

const history = createHistory();
const pushQueryString = qs => {
  history.push({
    search: qs
  });
};

export default class CompareQueryParams extends React.Component {
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
      state: queryParams.getState(),
      schoolId: queryParams.getSchoolId(),
      lat: queryParams.getLat(),
      lon: queryParams.getLon(),
      distance: queryParams.getDistance(),
      locationLabel:
        queryParams.getValueForKey('locationLabel') ||
        queryParams.getValueForKey('locationSearchString'),
      sort: queryParams.getSort() || (queryParams.getQ() ? 'relevance' : 'rating'),
      page: queryParams.getPage(),
      q: queryParams.getQ(),
      updateCompareSchool: (state,id) => {
        pushQueryString(queryParams.queryStringWithNewStateAndId(state,id));
      },
      updateSort: sort => {
        pushQueryString(queryParams.queryStringWithNewSort(sort));
      },
      updatePage: page => {
        pushQueryString(queryParams.queryStringWithNewPage(page));
      },
      updateDistance: distance => {
        pushQueryString(queryParams.queryStringWithNewDistance(distance));
      },
    };

    return this.props.children(extraProps);
  }
}