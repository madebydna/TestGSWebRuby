import React, { PropTypes } from 'react';
import NoDataModuleCta from './no_data_module_cta.jsx';
import SectionNavigation from './equity/tabs/section_navigation';
import ResponseData from './response_data.jsx';
import InfoCircle from './info_circle';
import AnchorButton from './anchor_button';

export default class PrivateSchoolInfo extends React.Component {

  static propTypes = {
    content: PropTypes.array,
    source_name: PropTypes.string
  };

  constructor(props) {
    super(props);
    this.state = {
      activeTabIndex: 0
    }
  }

  handleTabClick(index) {
    this.setState({activeTabIndex: index})
  }

  selectSectionContent(items) {
    let item = items[this.state.activeTabIndex];
    let data = item.data;

    return <div className={'tabs-panel tabs-panel_selected'}>
      <ResponseData input={data}/>
    </div>
  }

  drawInfoCircle(infoText) {
    if (infoText) {
      return(<InfoCircle
          content={infoText}
        />
      );
    } else {
      return null;
    }
  }

  render() {
    if (this.props.content) {

      let stuff = this.props.content;
      let items = stuff.map((h) => ({section_title: h.title}));
      let infoText = 'Replace this with real copy';
      return (<div id="private-school-info">
        <a className="anchor-mobile-offset" name="General_info"/>
        <div className="equity-container">
          <div className="title-bar">
            <div className='rating-layout circle-rating--equity-blue'>
              <span className='icon-general-info'/>
            </div>
            <div className="title-container">
              <div className="title">
                General Information
                <AnchorButton href={ this.props.osp_link } >Edit</AnchorButton>
                <p><br /></p>
              </div>
            </div>
          <div className="tab-buttons">
            <SectionNavigation key="sectionNavigation"
                               items={items}
                               active={this.state.activeTabIndex}
                               google_tracking={'General_info'}
                               onTabClick={this.handleTabClick.bind(this)}/>
          </div>
          <div className="top-tab-panel">{this.selectSectionContent(stuff)}</div>
          </div>
            <div className="source-bar">
            Source:&nbsp;<span className="sources-text">{this.props.source_name}</span>
          </div>
        </div>
      </div>)}
    else {
      return <div id="private-school-info" className="rating-container">
        <a className="anchor-mobile-offset" name="General_info"></a>
        <div className="rating-container__rating">
          <div className="module-header">
            <div className="circle-rating--equity-blue circle-rating--medium">
              <span className="icon-user"></span>
            </div>
            <div className="title-container">
              <div className="title">General Information <AnchorButton href={ this.props.osp_link } >Edit</AnchorButton></div>
              <NoDataModuleCta moduleName="General info"/>
            </div>
          </div>
        </div>
      </div>
    }
  }
}
