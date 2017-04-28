import React from 'react';
import { shallow } from 'enzyme';
import sinon from 'sinon';
import { expect } from 'chai';

import Drawer from '../app/bundles/GSWeb/react_components/drawer.jsx';

describe('<Drawer />', function() {
  it('when given content it says "Show more"', function() {
    global.GS = global.GS || {};
    GS.I18n = GS.I18n || {};
    GS.I18n.t = function(s) { return s; };
    const wrapper = shallow(<Drawer content="<div class='.some-class'></div>" />);
    expect(wrapper.text()).to.have.contain('Show more');
  });
});
