import React from 'react';
import PropTypes from 'prop-types';
import SchoolProfileComponent from 'react_components/equity/school_profile_component';
import { formatAndJoinAnchors } from '../../components/anchor_router';
import ModuleTab from 'react_components/school_profiles/module_tab';
import CommunityFeedback from 'react_components/school_profiles/community_feedback';
import ShareYourFeedbackCta from 'react_components/school_profiles/share_your_feedback_cta';
import ModuleSubTab from "../school_profiles/module_sub_tab";
import { scrollToElement } from '../../util/scrolling';

export default class StudentsWithDisabilities extends SchoolProfileComponent {

  constructor(props) {
    super(props);
    this.goToLastTab = this.goToLastTab.bind(this);
  }

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

  goToLastTab() {
    this.setState({
      active: this.filteredData().length
    });
    scrollToElement('.icon-disability-2');
  }

  activePane() {
    if(this.state.active < this.filteredData().length) {
      return <div>
        { super.activePane() }
        <ShareYourFeedbackCta buttonText={this.props.feedback.button_text} questionText={this.props.feedback.feedback_cta} buttonClicked={this.goToLastTab} />
      </div>
    }
    return <CommunityFeedback/>
  }
};

