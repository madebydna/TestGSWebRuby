import React from 'react';
import PropTypes from 'prop-types';
import SingleItemSelectable from './single_item_selectable';

export default class ButtonGroup extends React.Component {
  static propTypes = {
    options: PropTypes.object.isRequired,
    onSelect: PropTypes.func.isRequired,
    activeOption: PropTypes.string
  }

  render() {
    return <span>
      <SingleItemSelectable options={this.props.options}
        activeOption={this.props.activeOption}
        onSelect={this.props.onSelect}
        className='button-group'>
        {
          (key, label, active) =>
          <label key={key} className={active ? 'active' : ''}>
            {label}
          </label>
        }
      </SingleItemSelectable>
    </span>
  }
}
