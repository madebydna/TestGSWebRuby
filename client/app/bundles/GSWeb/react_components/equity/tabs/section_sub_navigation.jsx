import React from 'react';
import PropTypes from 'prop-types'; // importing from react is deprecated
import { formatAnchorString, hashSeparatorAnchor } from '../../../components/anchor_router';
import SectionNavigation from './section_navigation';

export default class SectionSubNavigation extends SectionNavigation {
  render() {
    let tabs = this.tabs();
    return <div className="sub-section-navigation">
      { tabs && <div className="sub-nav-group">{tabs}</div> }
    </div>
  };
};
