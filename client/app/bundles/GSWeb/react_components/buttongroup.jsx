import React from 'react';
import PropTypes from 'prop-types';

export default class ButtonGroup extends React.Component {
  static propTypes = {
    options: PropTypes.object.isRequired,
    onSelect: PropTypes.func.isRequired,
    activeOption: PropTypes.string
  }

  constructor(props) {
    super(props);
    this.state = {
      activeOption: props.activeOption
    }
  }

  componentWillReceiveProps(nextProps) {
    if(nextProps.activeOption && nextProps.activeOption != this.props.activeOption) {
      this.setState({ activeOption: nextProps.activeOption });
    }
  }

  handleSelect(option) {
    return () => {
      this.setState({ activeOption: option });
      this.props.onSelect(option);
    }
  }

  renderOptions() {
    return Object.keys(this.props.options).map(key => 
        <label key={key}
          className={key == this.state.activeOption ? 'active' : ''}
          onClick={this.handleSelect(key)}>
          {this.props.options[key]}
        </label>);
  } 

  render() {
    return <span className="button-group">{this.renderOptions()}</span>
  }
}
