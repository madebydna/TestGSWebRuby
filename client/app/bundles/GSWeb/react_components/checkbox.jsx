import React, { PropTypes } from 'react';

export default class Checkbox extends React.Component {

  static propTypes = {
    checked: React.PropTypes.bool
  }

  static defaultProps = {
    checked: false
  }

  constructor(props) {
    super(props);

    this.onToggle = this.onToggle.bind(this);
    this.state = {
      checked: this.props.checked
    }
  }

  onToggle(e) {
    this.setState({
      checked: !this.state.checked 
    });
    this.props.onClick(this.props.value);
  }

  render() {
    return <span onClick={this.onToggle} >
      <input type="checkbox" value={this.props.value} checked={this.state.checked} /><label>{this.props.label}</label>
    </span>
  }


}
