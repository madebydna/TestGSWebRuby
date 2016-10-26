class SubSectionToggle extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      active: 1
    }
  }

  renderContent() {
    var items = _.map(this.props.equity_config, function(item, index) {
      if(this.state.active === index) {
        return <div className={'tabs-panel tabs-panel_selected'}>
          <EquityContentPane key={item["component"]} graph={this.props.graph[item["component"]]} text={this.props.explanation[item["subject"]]} />
        </div>
      }
    }.bind(this));
    return items;
  }

  render() {
    return <div>
      <SectionSubNavigation items={this.props.equity_config} active={this.state.active} onTabClick={this.handleTabClick.bind(this)}/>
      {this.renderContent()}
    </div>
  }

  handleTabClick(index) {
    this.setState({active: index})
  }
};