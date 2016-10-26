class EquitySection extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      active: 0
    }
  }

  selectSectionContent(section_content) {
    let item = section_content[this.state.active];
    return <div className={'tabs-panel tabs-panel_selected'}>
      <SubSectionToggle
          equity_config={item["content"]}
      />
    </div>
  }

  render() {
    let section_info = this.props.equity_config["section_info"];
    let section_content = this.props.equity_config["section_content"];
    return <div className="equity_section">
      <div className="title_bar">{section_info.title} </div>
      <SectionNavigation items={section_content} active={this.state.active} onTabClick={this.handleTabClick.bind(this)}/>
      {this.selectSectionContent(section_content)}
    </div>
  }

  handleTabClick(index) {
    this.setState({active: index})
  }
};

Equity.propTypes = {
  equity_config: React.PropTypes.arrayOf(React.PropTypes.object({
    section_info: React.PropTypes.object,
    section_content: React.PropTypes.object
  }))
};