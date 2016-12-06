class NearestHighPerformingSchools extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      tabIndex: this.props.tabIndex || 0,
      tabNames: ['Nearest high-performing', 'All nearby'],
    }
  }

  createTabClickHandler(index) {
    return function() {
      this.setState({
        tabIndex: index
      });
    }.bind(this);
  }

  renderTabs() {
    let tabIndex = this.state.tabIndex;
    return this.state.tabNames.map(function(tabName, i) {
      return (
        <button className={tabIndex == i ? 'active' : ''} onClick={this.createTabClickHandler(i)} key={i}>
          {tabName}
        </button>
      );
    }.bind(this));
  }

  tabContentPanes() {
    let i = this.state.tabIndex;
    return [
      <TopPerformingNearbySchoolsList store={window.store} key={0} visible={i == 0}/>,
      <NearbySchoolsByDistanceList store={window.store} key={1} visible={i == 1} />
    ];
  }

  renderContentPanes() {
    return this.tabContentPanes().map(function(pane, i) {
      let display = this.state.tabIndex == i ? 'block' : 'none';
      return (
        <div style={{display: display}} key={i}>
          {pane}
        </div>
      )
    }.bind(this));
  }

  render() {
    return (<div>
      <a className="anchor-mobile-offset" name="NearbySchools"></a>
      <div className="nearby-schools">
        <div className="title-bar">
          <div className="title">{this.props.title}</div>
          <div className="button-bar">
            { this.renderTabs() }
          </div>
        </div>
        <div className="content">
          { this.renderContentPanes() }
        </div>
      </div>
    </div>);
  }
}

NearestHighPerformingSchools.propTypes = {
  tabIndex: React.PropTypes.number
};
