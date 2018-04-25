import React from 'react';
import PropTypes from 'prop-types';
import Select from '../select';
import Checkbox from '../checkbox';
import SchoolLevelFilter from './school_level_filter';

export default class FilterBar extends React.Component {

  static defaultProps = {
  }

  static propTypes = {
  }

  constructor(props) {
    super(props);
    this.state = {};
  }

  handleSchoolLevel(value) {
    
  }

  render() {
    return <SchoolLevelFilter handler={this.handleSchoolLevel} label='' />
  }
}
