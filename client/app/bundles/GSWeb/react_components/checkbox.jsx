import React from 'react';
import PropTypes from 'prop-types';

export default class Checkbox extends React.Component {
  static propTypes = {
    checked: PropTypes.bool,
    label: PropTypes.node.isRequired,
    onClick: PropTypes.func.isRequired,
    value: PropTypes.node.isRequired
  };

  static defaultProps = {
    checked: false
  };

  constructor(props) {
    super(props);

    this.onToggle = this.onToggle.bind(this);
    this.state = {
      checked: this.props.checked
    };
  }

  onToggle(e) {
    this.setState({
      checked: !this.state.checked
    });
    this.props.onClick(this.props.value);
  }

  render() {
    return (
      <span onClick={this.onToggle}>
        <input
          onChange={(e) => {}} // hack to silence React warning
          type="checkbox"
          value={this.props.value}
          checked={this.state.checked}
        />
        <label>{this.props.label}</label>
      </span>
    );
  }
}
