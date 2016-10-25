class TabToggle extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      tabs: this.initializeTabToggle(),
      active: 0
    }
  }

  initializeTabToggle() {
    return JSON.parse(JSON.stringify(this.props.tabs));
  }

  instantiateContentComponent(content){
    let data = content["data"];
    let component = content["component"];

    switch (component) {
      case 'EquityBarGraph': {
        return <EquityBarGraph test_scores= {data.test_scores} enrollment= {data.enrollment}/>;
      }
      default: {
        return 'ARGH2!!! ' + component;
      }
    }
  }

  renderAnArrayOfTabContents() {
    var items = _.map(this.state.tabs, function(item, index) {
      if(item["content"] !='') {
        return <div className={'tabs-panel ' + (this.state.active === index ? 'tabs-panel_selected' : '')}>
          {this.instantiateContentComponent(item["content"])}
        </div>;
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
      <TabToggleSwitcher items={myTabTitles} active={this.state.active} onTabClick={this.handleTabClick.bind(this)}/>
      <TabToggleContent items={myContentPanes} active={this.state.active} />
    </div>;
  }

  handleTabClick(index) {
    this.setState({active: index})
  }
};

class TabToggleSwitcher extends React.Component {
  render(){
    var active = this.props.active;
    var items = this.props.items.map(function(item, index) {
      return <a href="javascript:void(0)"
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

class TabToggleContent extends React.Component {
  render(){
    if(this.props.items != '') return <div>{this.props.items}</div>;
  }
};