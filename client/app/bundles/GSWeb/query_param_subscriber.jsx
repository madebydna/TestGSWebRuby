import React from 'react';
import PropTypes from 'prop-types';
import { getFromQueryString, addQueryParamToUrl } from 'util/uri';
import createHistory from 'history/createBrowserHistory';

const history = createHistory();

class QueryParamSubscriber extends React.Component {
  static propTypes = {
    paramConfigs: PropTypes.arrayOf(
      PropTypes.shape({
        param: PropTypes.string.isRequired,
        newName: PropTypes.string,
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

  writeParamToUrl(param, newValue, writeTransform) {
    const url = addQueryParamToUrl(
      param,
      writeTransform ? writeTransform(newValue) : newValue,
      window.location.href
    );
    window.history.pushState(null, null, url);
    this.forceUpdate();
  }

  render() {
    const obj = {};

    this.props.paramConfigs.forEach(config => {
      const {
        param,
        newName,
        funcName,
        readTransform,
        writeTransform
      } = config;

      const paramValue = getFromQueryString(param);
      if (newName) {
        obj[newName] = readTransform ? readTransform(paramValue) : paramValue;
      } else {
        obj[param] = readTransform ? readTransform(paramValue) : paramValue;
      }

      obj[funcName] = newValue =>
        this.writeParamToUrl(param, newValue, writeTransform);
    });
    return this.props.children(obj);
  }
}

export default QueryParamSubscriber;
