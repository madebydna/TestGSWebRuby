import React from 'react';
import PropTypes from 'prop-types';
import Select from '../select';
import Checkbox from '../checkbox';
import GradeLevelFilter from './grade_level_filter';
import EntityTypeFilter from './entity_type_filter';
import OpenableCloseable from 'react_components/openable_closeable';

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
    console.log('level filter: ' + value);
  }

  render() {
    return <OpenableCloseable openByDefault={false}>
      {
        (isOpen, {open, close}) =>
          <div className="filter-container">
            <div className="panel-triggers" style={{display: isOpen? 'none' : ''}}>
              <a onClick={open}>Filter</a>
            </div>
            <div className={"filter-panel " + (isOpen? '' : 'closed')}>
              <div className="top-controls">
                <div className="close" onClick={close}>X</div>
              </div>
              <div className="filters">
                <div className="filter">
                  <label>School type</label>
                  <EntityTypeFilter label='' />
                  <label>Grade level</label>
                  <GradeLevelFilter label='' />
                </div>
              </div>
              <div className="controls">
                <button onClick={close}>Apply</button>
              </div>
            </div>
          </div>
      }
    </OpenableCloseable>
  }
}
