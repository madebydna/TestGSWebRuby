import React from "react";
import PropTypes from "prop-types";
import TopSchools from "./top_schools";
import CsaTopSchools from "./csa_top_schools";
import { validSizes as validViewportSizes } from "util/viewport";
import SectionNavigation from '../equity/tabs/section_navigation';
import ModuleTab from 'react_components/school_profiles/module_tab';
import { t } from "util/i18n";

class TopSchoolsStateful extends React.Component {
  static propTypes = {
    schoolsData: PropTypes.object,
    size: PropTypes.oneOf(validViewportSizes).isRequired,
    locality: PropTypes.object.isRequired,
    community: PropTypes.string.isRequired,
    schoolLevels: PropTypes.object,
    summaryType: PropTypes.string.isRequired,
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
  }

  initialSchoolLoad({ elementary, middle, high, csa }) {
    if (elementary.length > 0) {
      this.state = {
        levelCodes: 'e'
      }
    } else if (middle.length > 0) {
      this.state = {
        levelCodes: 'm'
      }
    } else if (high.length > 0) {
      this.state = {
        levelCodes: 'h'
      }
    }
  }

  handleGradeLevel = (str) => {
    this.setState({
      levelCodes: str
    })
  }

  handleTabClick = (index) => {
    this.setState({ active: index });
  }

  tabs() {
    let tabs = [t('top_schools.top_schools')];
    if (this.props.schoolsData.csa.length > 0 && this.props.community !== "state") {
      tabs.push(t('csa_winners'));
    }
    return tabs;
  }
  
  makeTabs() {
    return this.tabs().map(function (item, index) {
      return <ModuleTab title={item} key={index} pageType={this.props.community} />
    }.bind(this));
  }
    
  renderTabsContainer = () => {
    let tabs = this.tabs();
    if (tabs.length === 1) {
      if (this.props.community === 'state') {
        return (
          <h3 dangerouslySetInnerHTML={{__html: t('top_schools.state_top_schools_header', { parameters: { state: this.props.locality.nameLong } })}} />
        );
      }
      return (
        <h3>{tabs[0]}</h3>
      );
    }
    return (
      <div className="tab-buttons">
        <SectionNavigation active={this.state.active} onTabClick={this.handleTabClick} badge={this.props.csa_badge} >
          { this.makeTabs() }
        </SectionNavigation>
      </div>
    );
  }

  render() {
    const TAB_CSA = 1;

    if (this.state.active === TAB_CSA) {
      return (
        <CsaTopSchools
          schools={this.props.schoolsData.csa}
          handleTabClick={this.handleTabClick}
          renderTabsContainer={this.renderTabsContainer}
          size={this.props.size}
          community={this.props.community}
          locality={this.props.locality}
        />
      );
    } else {
      return (
         <TopSchools
          schools={this.props.schoolsData}
          schoolLevels={this.props.schoolLevels}
          handleGradeLevel={this.handleGradeLevel}
          handleTabClick={this.handleTabClick}
          renderTabsContainer={this.renderTabsContainer}
          size={this.props.size}
          levelCodes={this.state.levelCodes}
          community={this.props.community}
          locality={this.props.locality}
          summaryType={this.props.summaryType}
        />
      );
    }
  }
}

export default TopSchoolsStateful;