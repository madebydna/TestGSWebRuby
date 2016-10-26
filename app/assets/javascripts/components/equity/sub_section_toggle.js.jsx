class SubSectionToggle extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      // tabs: this.initializeTabToggle(),
      active: 1
    }
  }

  // initializeTabToggle() {
  //   return JSON.parse(JSON.stringify(this.props.tabs));
  // }

  // instantiateContentComponent(content){
  //   let data = content["data"];
  //   let component = content["component"];
  //
  //   switch (component) {
  //     case 'EquityBarGraph': {
  //       let id = "equity_bar_graph"+_.uniqueId();
  //       return <EquityBarGraph test_scores= {data.test_scores} enrollment= {data.enrollment} graphId={id}/>;
  //     }
  //     default: {
  //       return 'ARGH2!!! ' + component;
  //     }
  //   }
  // }

  renderContent() {
    var items = _.map(this.props.equity_config, function(item, index) {
      if(this.state.active === index) {
         // console.log("select tab component:"+this.props.explanation[item["subject"]]);
        return <div className={'tabs-panel tabs-panel_selected'}>
          <EquityContentPane key={item["component"]} graph={this.props.graph[item["component"]]} text={this.props.explanation[item["subject"]]} />
        </div>
      }
    }.bind(this));
    return items;
  }

  render() {
    // myTabTitles = this.state.tabs;
    // myContentPanes = this.renderAnArrayOfTabContents();
    // for(var i=0; i < myContentPanes.length; i++){
    //   if(myContentPanes[i] == undefined){
    //     myTabTitles[i] = undefined;
    //   }
    // }

    return <div>
      <SectionSubNavigation items={this.props.equity_config} active={this.state.active} onTabClick={this.handleTabClick.bind(this)}/>
      {/*<TabToggleContent items={myContentPanes} active={this.state.active} />*/}
      {this.renderContent()}
    </div>
  }

  handleTabClick(index) {
    this.setState({active: index})
  }
};

class SectionSubNavigation extends React.Component {
  render(){
    var active = this.props.active;
    var items = this.props.items.map(function(item, index) {
      return <a href="javascript:void(0)"
                className={'tab ' + (active === index ? 'tab_selected' : '')}
                onClick={this.onClick.bind(this, index)}>
        {item.subject}
      </a>;
    }.bind(this));
    return <div>{items}</div>;
  }

  onClick(index) {
    this.props.onTabClick(index);
  }
};

// class TabToggleContent extends React.Component {
//   render(){
//     if(this.props.items != '') return <div>{this.props.items}</div>;
//   }
// };