class SubSectionToggle extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      active: 0
    }
  }

  renderContent() {
        let item = this.props.equity_config[this.state.active];
        return <div className={'tabs-panel tabs-panel_selected'}>
          <EquityContentPane graph={item["component"]} text={item["explanation"]} />
        </div>
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

Equity.propTypes = {
  equity_config: React.PropTypes.arrayOf(React.PropTypes.object({
        subject: React.PropTypes.string,
        component: React.PropTypes.object,
        explanation: React.PropTypes.string
  }))
};