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