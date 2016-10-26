class EquitySection extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      // tabs: this.initializeTabs(),
      active: 0
    }
  }

  // initializeTabs() {
  //   return JSON.parse(JSON.stringify(this.props.tabs));
  // }

  selectSectionContent() {
    var items = _.map(this.props.equity_config, function(item, index) {
      // let tabToggle = <TabToggle tabs={ item["content"] } />;
      if(this.state.active === index) {
        // console.log("select tab content:"+JSON.stringify(this.props.explanation));
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
    // myTabTitles = this.state.tabs;
    // contentPane = this.selectTabContent();
    // for(var i=0; i < myContentPanes.length; i++){
    //   if(myContentPanes[i] == undefined){
    //     myTabTitles[i] = undefined;
    //   }
    // }
    // console.log("equity section render:"+JSON.stringify(this.props.equity_config));

    return <div>
      <SectionNavigation items={this.props.equity_config} active={this.state.active} onTabClick={this.handleTabClick.bind(this)}/>
      {this.selectSectionContent()};
    </div>;
  }

  handleTabClick(index) {
    this.setState({active: index})
  }
};

class SectionNavigation extends React.Component {
  render(){
    var active = this.props.active;

    var items = _.map(this.props.items, function(item, index) {
      return <a href="javascript:void(0)"
                className={'tab ' + (active === index ? 'tab_selected' : '')}
                onClick={this.onClick.bind(this, index)}>
        {item.section_title}
      </a>;
    }.bind(this));
    if(items != undefined ) return <div>{items}</div>;
  }

  onClick(index) {
    this.props.onTabClick(index);
  }
};
//
// class TabsContent extends React.Component {
//   render(){
//     if(this.props.items != undefined ) return <div>{this.props.items}</div>;
//   }
// };