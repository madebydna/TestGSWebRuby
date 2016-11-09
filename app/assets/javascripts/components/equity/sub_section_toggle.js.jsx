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
          <EquityContentPane key={this.state.active} graph={item["component"]} text={item["explanation"]} />
        </div>
  }

  render() {
    return <div>
      <div className="sub-section-navigation">
        <SectionSubNavigation items={this.props.equity_config} active={this.state.active} onTabClick={this.handleTabClick.bind(this)}/>
      </div>
      {this.renderContent()}
    </div>
  }

  handleTabClick(index) {
    this.setState({active: index})
  }
}

SubSectionToggle.propTypes = {
  equity_config: React.PropTypes.arrayOf(React.PropTypes.shape({
    subject: React.PropTypes.string,
    component: React.PropTypes.object,
    explanation: React.PropTypes.element
  }))
};