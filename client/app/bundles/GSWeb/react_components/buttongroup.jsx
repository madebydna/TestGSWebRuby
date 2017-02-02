import React, { PropTypes } from 'react';

export default class ButtonGroup extends React.Component {
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
        <button key={key}
          className={key == this.state.activeOption ? 'active' : ''}
          onClick={this.handleSelect(key)}>
          {this.props.options[key]}
        </button>);
  } 

  render() {
    return <span className="button-group">{this.renderOptions()}</span>
  }
}
