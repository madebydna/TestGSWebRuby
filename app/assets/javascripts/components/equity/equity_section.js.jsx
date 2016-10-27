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
          key={this.state.active}
          equity_config={item["content"]}
      />
    </div>
  }
  createRatingCircle(rating, icon) {
    let rating_html = '';
    if (rating != '') {
      let circleClassName = 'circle-rating--medium rating-layout circle-rating--'+rating;
      rating_html = <div className={circleClassName}>{rating}</div>;
    }
    else{
      let circleClassName = 'circle-rating--medium rating-layout circle-rating--equity-blue';
      rating_html = <div className={circleClassName}><span className={icon}></span></div>;
    }
    return rating_html
  }

  render() {
    let section_info = this.props.equity_config["section_info"];
    let section_content = this.props.equity_config["section_content"];
    let rating = this.createRatingCircle(section_info.rating, section_info.icon_classes);

    return <div className="equity-section">
      <div className="title-bar">{rating}{section_info.title}</div>
      <SectionNavigation items={section_content} active={this.state.active} onTabClick={this.handleTabClick.bind(this)}/>
      <div className="top-tab-panel">{this.selectSectionContent(section_content)}</div>
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