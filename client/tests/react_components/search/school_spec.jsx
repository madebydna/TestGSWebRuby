import React from 'react';
import { shallow } from 'enzyme';
import sinon from 'sinon';
import { expect } from 'chai';
import { describe, it } from 'mocha';

// NOTE: this needs to be commented out until we figure out how to 
// tell webpack/mocha to load images from app/assets/images
// import School from 'react_components/search/school';

describe.skip('<School />', () => {
  it('renders the school name', () => {
    const wrapper = shallow(<School name="A High School" />);
    expect(wrapper.text()).to.contain('A High School');
  });

  it('links to school profile', () => {
    const wrapper = shallow(
      <School name="A High School" links={{ profile: 'foo' }} />
    );
    const link = wrapper.find({ href: 'foo' });
    expect(link.text()).to.contain('A High School');
  });

  it('Correctly formats number of students', () => {
    let wrapper = shallow(<School enrollment={2} />);
    expect(wrapper.text()).to.match(/.*\b2 students.*/);
    wrapper = shallow(<School enrollment={1} />);
    expect(wrapper.text()).to.match(/.*1 student\b.*/);
  });

  describe('Address', () => {
    let state = 'CA';
    let address = {};
    const school = () => shallow(<School state={state} address={address} />);
    const addressDiv = () => school().find('.address');
    const hasAddress = () => addressDiv().length > 0;
    const renderedAddress = () => addressDiv().text();

    it('Correctly formats standard address', () => {
      address = {
        street1: '1999 Harrison st',
        city: 'Oakland',
        zip: '94612'
      };
      expect(renderedAddress()).to.contain(
        '1999 Harrison st, Oakland, CA, 94612'
      );
    });

    it('Correctly formats address with blank street1', () => {
      address = {
        street1: '',
        city: 'Oakland',
        zip: '94612'
      };
      expect(renderedAddress()).to.eq('Oakland, CA, 94612');
    });

    it('Correctly formats address with blank street and zipcode', () => {
      address = {
        street1: '',
        city: 'Oakland',
        zip: ''
      };
      expect(renderedAddress()).to.eq('Oakland, CA');
    });

    it('Omits address if missing city or state', () => {
      address = {
        street1: '123 main st',
        zip: '94612'
      };
      expect(hasAddress()).to.eq(false);
      address = {
        street1: '123 main st',
        city: 'Oakland',
        zip: '94612'
      };
      state = null;
      expect(hasAddress()).to.eq(false);
    });
  });
});
