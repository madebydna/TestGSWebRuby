import React, { PropTypes } from 'react';
import SectionSubNavigation from './tabs/section_sub_navigation';
import EquityContentPane from './equity_content_pane';
import { handleThirdAnchor, addAnchorChangeCallback, removeAnchorChangeCallback } from '../../components/anchor_router';

export default class SubSectionToggle extends React.Component {

  static propTypes = {
    defaultTab: React.PropTypes.string,
    parent_anchor: React.PropTypes.string,
    top_anchor: React.PropTypes.string,
    panes: React.PropTypes.arrayOf(React.PropTypes.shape({
      anchor: React.PropTypes.string,
      title: React.PropTypes.string,
      component: React.PropTypes.object,
      explanation: React.PropTypes.element
    }))
  };

  constructor(props) {
    super(props);
    this.selectTabMatchingAnchor = this.selectTabMatchingAnchor.bind(this);
    let defaultTabIndex = 0;
    if(props.defaultTab) {
      defaultTabIndex = this.tabNames().indexOf(props.defaultTab);
    }
    this.state = {
      active: defaultTabIndex
    };
  }

  selectTabMatchingAnchor() {
    handleThirdAnchor(
      this.props.parent_anchor, tokens => {
        let index = this.props.panes.findIndex((config) => {
          return this.buttonAnchorName(config.anchor) == tokens[0];
        });
        if(index == -1) {
          index = 0;
        }
        this.setState({ active: index });
      }
    );
  }

  componentDidMount() {
    this.selectTabMatchingAnchor();
    addAnchorChangeCallback(this.selectTabMatchingAnchor);
  }

  componentWillUnmount() {
    removeAnchorChangeCallback(this.selectTabMatchingAnchor);
  }

  buttonAnchorName(value) {
    if(!value) {
      return value;
    }
    return value.replace(/\s/g, "_");
  }

  render() {
    let pane = this.props.panes[this.state.active];

    return <div>
      <div className="sub-section-navigation">
        <SectionSubNavigation
          items={this.props.panes}
          active={this.state.active}
          onTabClick={this.handleTabClick.bind(this)}
          parent_anchor={this.props.parent_anchor}
          top_anchor={this.props.top_anchor}
        />
      </div>
      <div className={'tabs-panel tabs-panel_selected'}>
        <EquityContentPane
          key={this.state.active}
          graph={pane.component}
          text={pane.explanation} />
      </div>
    </div>
  }

  handleTabClick(index) {
    this.setState({active: index})
  }
}
