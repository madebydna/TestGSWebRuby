import React from 'react';
import { shallow } from 'enzyme';
import sinon from 'sinon';
import { expect } from 'chai';

import Drawer from '../app/bundles/GSWeb/react_components/drawer';

describe('<Drawer />', () => {
  it('when given content it says "Show more"', () => {
    global.GS = global.GS || {};
    const wrapper = shallow(
      <Drawer
        content="<div class='.some-class'></div>"
        closedLabel="Show more"
      />
    );
    expect(wrapper.text()).to.contain('Show more');
  });
});
