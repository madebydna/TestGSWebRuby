class SectionSubNavigation extends React.Component {
  render(){
    var active = this.props.active;
    var items = this.props.items.map(function(item, index) {
      return <a href="javascript:void(0)"
                className={'sub-nav-item ' + (active === index ? 'sub-tab-selected' : '')}
                onClick={this.onClick.bind(this, index)}>
        {item.subject}
      </a>;
    }.bind(this));
    return <div className="sub-nav-group">{items}</div>;
  }

  onClick(index) {
    this.props.onTabClick(index);
  }
};