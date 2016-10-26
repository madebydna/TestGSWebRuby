class EquitySection extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      active: 0
    }
  }

  selectSectionContent() {
    let item = this.props.equity_config[this.state.active];
    return <div className={'tabs-panel tabs-panel_selected'}>
      <SubSectionToggle
          equity_config={item["content"]}
      />
    </div>
  }

  render() {
    return <div>
      <SectionNavigation items={this.props.equity_config} active={this.state.active} onTabClick={this.handleTabClick.bind(this)}/>
      {this.selectSectionContent()};
    </div>
  }

  handleTabClick(index) {
    this.setState({active: index})
  }
};

Equity.propTypes = {
  equity_config: React.PropTypes.arrayOf(React.PropTypes.object({
    section_title: React.PropTypes.string,
    content: React.PropTypes.object
  }))
};