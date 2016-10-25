class Tabs extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      tabs: this.initializeTabs(),
      active: 0
    }
  }

  initializeTabs() {
    return JSON.parse(JSON.stringify(this.props.tabs));
  }

  renderAnArrayOfTabContents() {
    var items = _.map(this.state.tabs, function(item, index) {
      let tabToggle = <TabToggle tabs={ item["content"] } />;
      if(tabToggle != '') {
        return <div className={'tabs-panel ' + (this.state.active === index ? 'tabs-panel_selected' : '')}>{ tabToggle }</div>;
      }
    }.bind(this));
    return items;
  }

  render() {
    myTabTitles = this.state.tabs;
    myContentPanes = this.renderAnArrayOfTabContents();
    for(var i=0; i < myContentPanes.length; i++){
      if(myContentPanes[i] == undefined){
        myTabTitles[i] = undefined;
      }
    }

    return <div>
      <TabsSwitcher items={myTabTitles} active={this.state.active} onTabClick={this.handleTabClick.bind(this)}/>
      <TabsContent items={myContentPanes}/>
    </div>;
  }

  handleTabClick(index) {
    this.setState({active: index})
  }
};

class TabsSwitcher extends React.Component {
  render(){
    var active = this.props.active;

    var items = _.map(this.props.items, function(item, index) {
      return <a href="javascript:void(0)"
                className={'tab ' + (active === index ? 'tab_selected' : '')}
                onClick={this.onClick.bind(this, index)}>
        {item.tab_name}
      </a>;
    }.bind(this));
    if(items != undefined ) return <div>{items}</div>;
  }

  onClick(index) {
    this.props.onTabClick(index);
  }
};
//
class TabsContent extends React.Component {
  render(){
    if(this.props.items != undefined ) return <div>{this.props.items}</div>;
  }
};