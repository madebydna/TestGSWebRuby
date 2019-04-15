import React from "react";
import PropTypes from "prop-types";
import TopSchools from "./top_schools";
import CsaTopSchools from "./csa_top_schools";
import School from "react_components/search/school";
import { SM, validSizes as validViewportSizes } from "util/viewport";
import * as APISchools from 'api_clients/schools';
import SectionNavigation from '../equity/tabs/section_navigation';
import ModuleTab from 'react_components/school_profiles/module_tab';
import DataModule from 'react_components/data_module';
import { handleAnchor, handleThirdAnchor, addAnchorChangeCallback, removeAnchorChangeCallback, formatAnchorString, formatAndJoinAnchors } from '../../components/anchor_router';
import { t } from "util/i18n";

class TopSchoolsStateful extends React.Component {
  static propTypes = {
    schoolsData: PropTypes.object,
    size: PropTypes.oneOf(validViewportSizes).isRequired,
    locality: PropTypes.object.isRequired,
    community: PropTypes.string.isRequired,
    schoolLevels: PropTypes.object,
  };

  static defaultProps = {
    schoolsData: {},
    schoolLevels: {},
    active: 0
  };

  constructor(props) {
    super(props);
    this.state = {
      size: props.size,
      schoolLevels: props.schoolLevels,
      active: props.active 
    };
    this.initialSchoolLoad(props.schoolsData);
    this.handleGradeLevel = this.handleGradeLevel.bind(this);
    this.handleTabClick = this.handleTabClick.bind(this);
    this.renderTabsContainer = this.renderTabsContainer.bind(this);
  }

  initialSchoolLoad({ elementary, middle, high, csa }) {
    if (elementary.length > 0) {
      this.state = {
        levelCodes: 'e',
        schools: elementary
      }
    } else if (middle.length > 0) {
      this.state = {
        levelCodes: 'm',
        schools: middle
      }
    } else if (high.length > 0) {
      this.state = {
        levelCodes: 'h',
        schools: high
      }
    } else if (csa.length > 0) {
      this.state = {
        schools: csa
      }
    }
  }

  handleGradeLevel(str){
    const schools = { 
      'e': this.props.schoolsData.elementary, 
      'm': this.props.schoolsData.middle, 
      'h': this.props.schoolsData.high
    }
    this.setState({
      levelCodes: str,
      schools: schools[str]
    })
  }

  handleTabClick(index) {
    this.setState({ active: index });
  }
  
  tabs() {
    let tabs = [t('top_schools.top_schools')];
    if (this.props.schoolsData.csa.length > 0) {
      tabs.push(t('csa_winners'));
    }
    return tabs.map(function (item, index) {
      return <ModuleTab title={item} key={index} />
    }.bind(this));
  }
    
  renderTabsContainer() {
    return (
      <div className="tab-buttons">
        <SectionNavigation active={this.state.active} onTabClick={this.handleTabClick} badge={this.props.csa_badge} >
          { this.tabs() }
        </SectionNavigation>
      </div>
    );
  }

  render() {
    if (this.state.active === 1) {
      return (
        <CsaTopSchools
          schools={this.props.schoolsData.csa}
          handleTabClick={this.handleTabClick}
          renderTabsContainer={this.renderTabsContainer}
          size={this.props.size}
          locality={this.props.locality}
        />
      );
    } else {
      return (
         <TopSchools
          schools={this.state.schools}
          schoolLevels={this.props.schoolLevels}
          handleGradeLevel={this.handleGradeLevel}
          handleTabClick={this.handleTabClick}
          renderTabsContainer={this.renderTabsContainer}
          size={this.props.size}
          levelCodes={this.state.levelCodes}
          community={this.props.community}
          locality={this.props.locality}
        />
      );
    }
  }
}

export default TopSchoolsStateful;