import React from 'react';
import PropTypes from 'prop-types'; // importing from react is deprecated

export default class TabsWithPanes extends React.Component {
  static propTypes = {
    tabsContainer: PropTypes.element,
    panes: PropTypes.arrayOf(PropTypes.element).isRequired,
    active: PropTypes.number,
    anchor: PropTypes.string,
  };

  static defaultProps = {
    active: 0
  }

  constructor(props) {
    super(props);
    this.handleTabClick = this.handleTabClick.bind(this);
    this.state = {
      active: props.active
    };
  }

  componentWillReceiveProps(nextProps) {
    if(nextProps.active != this.props.active) {
      this.setState({active: nextProps.active})
    }
  }

  tabsContainer() {
    if (this.props.tabsContainer) {
      return React.cloneElement(this.props.tabsContainer, {
        onTabClick: this.handleTabClick,
        active: this.state.active
      })
    }
  }

  activePane() {
    return this.props.panes[this.state.active];
  }

  render() {
    return <div>
      {this.tabsContainer()}
      {this.activePane()}
    </div>
  }

  handleTabClick(index) {
    this.setState({active: index})
  }
}
