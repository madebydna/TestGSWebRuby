import React from 'react';
import { shallow } from 'enzyme';
import sinon from 'sinon';
import { expect } from 'chai';
import { jsdom } from 'jsdom';
import { mount } from 'enzyme';

import ReportReview from '../app/bundles/GSWeb/react_components/review/report_review.jsx';
import SpinnyWheel from '../app/bundles/GSWeb/react_components/spinny_wheel';


global.document = jsdom('');
global.window = document.defaultView;
global.gon = {
  links: {}
};

describe('<ReportReview />', function() {
  let cancelCallback = () => {};
  let reportedCallback = () => {};

  it('renders nothing when closed', function() {
    const wrapper = shallow(
      <ReportReview
        review={{}}
        cancelCallback={cancelCallback}
        reportedCallback={reportedCallback}
        open={false}/>
    );
    expect(wrapper.text()).to.be.empty;
  });

  it('renders header when open', function() {
    const wrapper = shallow(
      <ReportReview
        review={{}}
        cancelCallback={cancelCallback}
        reportedCallback={reportedCallback}
        open={true}/>
    );
    expect(wrapper.text()).to.contain('Report this review as inappropriate');
  });

  it('renders a spinny when disabled', function() {
    const wrapper = shallow(
      <ReportReview
        review={{}}
        cancelCallback={cancelCallback}
        reportedCallback={reportedCallback}
        open={true}/>
    );

    wrapper.setState({disabled: true});
    expect(wrapper.matchesElement(
      <SpinnyWheel/>
    )).to.equal(true);
  });

  it('invokes api when submit clicked', function() {
    cancelCallback = sinon.spy();
    reportedCallback = sinon.spy();

    const wrapper = mount(
      <ReportReview
        review={{id: 1}}
        cancelCallback={cancelCallback}
        reportedCallback={reportedCallback}
        open={true}/>
    );
    let cancelButton = wrapper.find('.button').first()
    cancelButton.simulate('click');
    expect(cancelCallback.calledOnce).to.equal(true);
  });


});
