import React, { PropTypes } from 'react';
import NoDataModuleCta from './no_data_module_cta.jsx'

export default class PrivateSchoolInfo extends React.Component {

  static propTypes = {
    best_known_for: React.PropTypes.string,
    anything_else: React.PropTypes.string,
    general_info: React.PropTypes.array
  };

  constructor(props) {
    super(props);
    this.state = {
      activeTabIndex: 0
    }
  }

  generalInfo() {
    return this.props.general_info.map((info) => <li>{info}</li>);
  }

  render() {
    let schoolDescriptions = this.props.general_info;
    if (schoolDescriptions.length > 0) {
      return (<div id="private-school-info">
        <a className="anchor-mobile-offset" name="General_info"/>
        <div className="private-school-info-container">
          <div className="title-bar">
            General Info
          </div>
          <div className="info-pane">
            <ul>
              {this.generalInfo()}
            </ul>
          </div>
          <div className="source-bar">
            Source:&nbsp;<span className="sources-text">School Admin</span>
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
              <div className="title">General Info</div>
              <NoDataModuleCta moduleName="General info"/>
            </div>
          </div>
        </div>
      </div>
    }
  }
}