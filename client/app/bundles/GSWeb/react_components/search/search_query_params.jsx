import React from 'react';
import PropTypes from 'prop-types';
import * as queryParams from './query_params';
import createHistory from 'history/createBrowserHistory';

const history = createHistory();
const pushQueryString = qs => {
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
      sort: queryParams.getSort(),
      page: queryParams.getPage(),
      q: queryParams.getQ(),
      updateLevelCodes: codes => {
        pushQueryString(queryParams.queryStringWithNewGradeLevels(codes));
      },
      updateEntityTypes: types => {
        pushQueryString(queryParams.queryStringWithNewEntityTypes(types));
      },
      updateSort: sort => {
        pushQueryString(queryParams.queryStringWithNewSort(sort));
      },
      updatePage: page => {
        pushQueryString(queryParams.queryStringWithNewPage(page));
      },
      updateDistance: distance => {
        pushQueryString(queryParams.queryStringWithNewDistance(distance));
      }
    };

    return this.props.children(extraProps);
  }
}
