import React, { PropTypes } from 'react';

export default class Multibutton extends React.Component {
  static propTypes = {
    options: React.PropTypes.object.isRequired,
    onSelect: React.PropTypes.func.isRequired,
    activeOption: React.PropTypes.string
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
        <span key={key}
          className={key == this.state.activeOption ? 'active' : ''}
          onClick={this.handleSelect(key)}>
          {this.props.options[key]}
        </span>);
  } 

  render() {
    return <span className="multi-button">{this.renderOptions()}</span>
  }
}
