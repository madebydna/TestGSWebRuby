class Tabs extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      tabs: this.initializeTabs(),
      active: 0
    }
  }

  initializeTabs() {
    // console.log("Peace Out my brother 1:"+this.props.tabs);
    return JSON.parse(JSON.stringify(this.props.tabs));
  }

  render() {
    // console.log("Peace Out my brother 2:"+this.state.tabs);
    return <div>
      <TabsSwitcher items={this.state.tabs} active={this.state.active} onTabClick={this.handleTabClick.bind()}/>
      <TabsContent items={this.state.tabs} active={this.state.active}/>
    </div>;
  }

  handleTabClick(index) {
    console.log("handleTabClick:"+index +"   this:"+this)
    this.setState({active: index})
  }
};

class TabsSwitcher extends React.Component {
  render(){
    // console.log(this.props.items);
    var active = this.props.active;
    var items = this.props.items.map(function(item, index) {
      return <a href="#"
                className={'tab ' + (active === index ? 'tab_selected' : '')}
                onClick={this.onClick.bind(this, index)}>
        {item.tab_name}
      </a>;
    }.bind(this));
    return <div>{items}</div>;
  }

  onClick(index) {
    this.props.onTabClick(index);
  }
};
//
class TabsContent extends React.Component {
  render(){
    var active = this.props.active;
    // var items = this.props.items.map(function(item, index) {
      // return <div key={index} className={'tabs-panel ' + (active === index ? 'tabs-panel_selected' : '')}>{item}</div>;
    // });
    return <div>{this.props.items.content}</div>;
  }
};