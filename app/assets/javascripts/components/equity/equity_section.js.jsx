class EquitySection extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      active: 0
    }
  }

  selectSectionContent() {
    var items = _.map(this.props.equity_config, function(item, index) {
      if(this.state.active === index) {
        return <div className={'tabs-panel tabs-panel_selected'}>
          <SubSectionToggle
              equity_config={item["content"]}
              graph={ this.props.graph }
              explanation={ this.props.explanation } />
        </div>;
      }
    }.bind(this));
    return items;
  }

  render() {
    return <div>
      <SectionNavigation items={this.props.equity_config} active={this.state.active} onTabClick={this.handleTabClick.bind(this)}/>
      {this.selectSectionContent()};
    </div>;
  }

  handleTabClick(index) {
    this.setState({active: index})
  }
};