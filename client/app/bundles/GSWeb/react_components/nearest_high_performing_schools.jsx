import React, { PropTypes } from 'react';
import { Provider, connect } from 'react-redux';
import TopPerformingNearbySchoolsList from './top_performing_nearby_schools_list';
import NearbySchoolsByDistanceList from './nearby_schools_by_distance_list';
import ButtonGroup from './buttongroup';

class NearestHighPerformingSchools extends React.Component {

  static propTypes = {
    tabIndex: React.PropTypes.number
  };

  constructor(props) {
    super(props);
    this.tabNames = this.tabNames.bind(this);
    this.state = {
      tabIndex: this.props.tabIndex || 0,
    }
  }

  tabNames() {
    return [GS.I18n.t('Nearest high-performing'), GS.I18n.t('Nearby schools')]
  }

  tabSwitched(index) {
    this.setState({
      tabIndex: index
    });
  }

  trackTabChanged() {
    window.analyticsEvent('Profile', 'Nearby Schools Toggle', this.tabNames()[this.state.tabIndex]);
  }

  componentDidUpdate(prevProps, prevState) {
    if(prevState.tabIndex !== this.state.tabIndex) {
      this.trackTabChanged();
    }
  }

  renderTabs() {
    let tabs = this.tabNames().reduce((accum, name, index) => ({...accum, [index]: name}), {});
    return <ButtonGroup
              activeOption={this.state.tabIndex.toString()}
              options={tabs}
              onSelect={this.tabSwitched.bind(this)} />
  }

  tabContentPanes() {
    let i = this.state.tabIndex;
    let panes = [
      <TopPerformingNearbySchoolsList
        store={window.store}
        key={0}
        visible={i == 0}
      />,
      <NearbySchoolsByDistanceList
        store={window.store}
        key={1}
        visible={i == 1}
      />
    ];
    return panes;
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
    return (<div id="NearbySchools">
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

// const NearestHighPerformingSchools = function(props, _railsContext) {
//   return(<Provider store={appStore}>
//     <NearestHighPerformingSchools  />
//   </Provider>);
// }
const ConnectedNearestHighPerformingSchools = connect(state => ({
  schoolState: state.school.state
}))(NearestHighPerformingSchools);

export default () => {
  return (
    <Provider store={window.store}>
      <ConnectedNearestHighPerformingSchools />
    </Provider>
  );
}
