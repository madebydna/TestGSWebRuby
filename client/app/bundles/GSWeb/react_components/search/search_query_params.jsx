import React from 'react';
import PropTypes from 'prop-types';
import * as queryParams from './query_params';
import createHistory from 'history/createBrowserHistory';

const history = createHistory();
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
      sort: queryParams.getSort(),
      page: queryParams.getPage(),
      updateLevelCodes: codes => {
        history.push({
          search: queryParams.queryStringWithNewGradeLevels(codes)
        });
      },
      updateEntityTypes: types => {
        history.push({
          search: queryParams.queryStringWithNewEntityTypes(types)
        });
      },
      updateSort: sort => {
        history.push({
          search: queryParams.queryStringWithNewSort(sort)
        });
      },
      updatePage: page => {
        history.push({
          search: queryParams.queryStringWithNewPage(page)
        });
      }
    };

    return this.props.children(extraProps);
  }
}
