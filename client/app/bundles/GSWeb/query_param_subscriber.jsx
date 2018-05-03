import React from 'react';
import PropTypes from 'prop-types';
import { getFromQueryString, putIntoQueryString } from 'util/uri';
import createHistory from 'history/createBrowserHistory';

const history = createHistory();

class QueryParamSubscriber extends React.Component {
  static propTypes = {
    paramConfigs: PropTypes.arrayOf(
      PropTypes.shape({
        param: PropTypes.string.isRequired,
        propName: PropTypes.string,
        funcName: PropTypes.string.isRequired,
        readTransform: PropTypes.func,
        writeTransform: PropTypes.func
      })
    ).isRequired,
    children: PropTypes.func.isRequired
  };

  constructor(props) {
    super(props);
    this.writeParamToUrl = this.writeParamToUrl.bind(this);
    this.state = {};
  }

  componentDidMount() {
    history.listen(() => {
      this.forceUpdate();
    });
  }

  writeParamToUrl(param, newValue, writeTransform, otherState = {}) {
    newValue = writeTransform ? writeTransform(newValue) : newValue;
    let query = putIntoQueryString(
      history.location.search,
      param,
      newValue,
      true
    );
    for (const otherParam of Object.keys(otherState)) {
      query = putIntoQueryString(
        query,
        otherParam,
        otherState[otherParam],
        true
      );
    }
    history.push({ search: query });
    this.forceUpdate();
  }

  render() {
    const obj = {};

    this.props.paramConfigs.forEach(config => {
      const {
        param,
        propName,
        funcName,
        readTransform,
        writeTransform,
        otherState
      } = config;

      const paramValue = getFromQueryString(
        param,
        history.location.search.substring(1)
      );
      if (propName) {
        obj[propName] = readTransform ? readTransform(paramValue) : paramValue;
      } else {
        obj[param] = readTransform ? readTransform(paramValue) : paramValue;
      }

      obj[funcName] = newValue =>
        this.writeParamToUrl(param, newValue, writeTransform, otherState);
    });
    return this.props.children(obj);
  }
}

export default QueryParamSubscriber;
