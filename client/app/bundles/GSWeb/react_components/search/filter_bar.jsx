import React from 'react';
import PropTypes from 'prop-types';
import OpenableCloseable from 'react_components/openable_closeable';
import GradeLevelFilter from './grade_level_filter';
import EntityTypeFilter from './entity_type_filter';
import DistanceFilter from './connected_distance_filter';

export default class FilterBar extends React.Component {
  static defaultProps = { includeDistance: false };

  static propTypes = { includeDistance: PropTypes.bool };

  constructor(props) {
    super(props);
    this.state = {};
  }

  render() {
    return (
      <OpenableCloseable openByDefault={false}>
        {(isOpen, { open, close }) => (
          <div className="filter-container">
            <div
              className="panel-triggers"
              style={{ display: isOpen ? 'none' : '' }}
            >
              <a onClick={open}>Filter</a>
            </div>
            <div className={`filter-panel ${isOpen ? '' : 'closed'}`}>
              <div className="top-controls">
                <div className="close" onClick={close}>
                  X
                </div>
              </div>
              <div className="filters">
                <div className="filter">
                  <label>School type</label>
                  <EntityTypeFilter label="" />
                  <label>Grade level</label>
                  <GradeLevelFilter label="" />
                  {this.props.includeDistance ? (
                    <React.Fragment>
                      <label>Distance</label>
                      <DistanceFilter />
                    </React.Fragment>
                  ) : null}
                </div>
              </div>
              <div className="controls">
                <button onClick={close}>Done</button>
              </div>
            </div>
          </div>
        )}
      </OpenableCloseable>
    );
  }
}
