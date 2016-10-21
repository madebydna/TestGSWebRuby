class TabToggle extends React.Component {
  constructor(props) {
    super(props);
  }

  getInitialState() {
    return {
      tabs: [
        {title: 'first', content: 'Content 1'},
        {title: 'second', content: 'Content 2'}
      ],
      active: 0
    };
  }

  render() {
    return <div>
      <TabToggleSwitcher items={this.state.tabs} active={this.state.active} onTabClick={this.handleTabClick.bind()}/>
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
      return <a href="#"
                className={'tab ' + (active === index ? 'tab_selected' : '')}
                onClick={this.onClick.bind(this, index)}>
        {item.title}
      </a>;
    }.bind(this));
    return <div>{items}</div>;
  };

  onClick(index) {
    this.props.onTabClick(index);
  }
};

class TabToggleContent extends React.Component {
  render() {
    var active = this.props.active;
    var items = this.props.items.map(function(item, index) {
      return <div className={'tabs-panel ' + (active === index ? 'tabs-panel_selected' : '')}>{item.content}</div>;
    });
    return <div>{items}</div>;
  }
};
