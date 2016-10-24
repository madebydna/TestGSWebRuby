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

  render() {
    return <div>
      <TabToggleSwitcher items={this.state.tabs} active={this.state.active} onTabClick={this.handleTabClick.bind(this)}/>
      <TabToggleContent items={this.state.tabs} active={this.state.active}/>
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
//
class TabToggleContent extends React.Component {
  render(){
    var active = this.props.active;
    var items = this.props.items.map(function(item, index) {
      return <div key={index} className={'tabs-panel ' + (active === index ? 'tabs-panel_selected' : '')}>{JSON.stringify(item)}</div>;
    });
    return <div>{items}</div>;
  }
};