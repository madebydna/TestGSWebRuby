import React, { PropTypes } from 'react';
import SchoolProfileComponent from 'react_components/equity/school_profile_component';
import { formatAndJoinAnchors } from '../../components/anchor_router';
import ModuleTab from 'react_components/school_profiles/module_tab';
import CommunityFeedback from 'react_components/school_profiles/community_feedback';
import ModuleSubTab from "../school_profiles/module_sub_tab";

export default class StudentsWithDisabilities extends SchoolProfileComponent {

  tabs() {
    return this.filteredData().map(function (item, index) {
      let anchorLink;
      if(item.anchor){
        anchorLink = formatAndJoinAnchors(this.props.anchor, item.anchor);
      }
      return <ModuleTab {...item} key={index} anchorLink={anchorLink} />
    }.bind(this)).concat([
      <ModuleTab
        title="Community feedback"
        key={this.filteredData().length}
      />
    ])
  }

  activePane() {
    if(this.state.active < this.filteredData().length) return super.activePane();
    return <CommunityFeedback/>
  }
};

