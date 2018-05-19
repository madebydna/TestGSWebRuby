/* eslint-disable no-return-assign */

import React from 'react';
import { mount, shallow } from 'enzyme';
import sinon from 'sinon';
import { expect } from 'chai';
import { before, describe, describe as context, it } from 'mocha';

import DistanceFilter from 'react_components/search/distance_filter';

describe('<DistanceFilter />', () => {
  let distance;
  const onChange = sinon.spy();
  const filterNode = () =>
    shallow(<DistanceFilter distance={distance} onChange={onChange} />);

  context('When not given a distance', () => {
    before(() => (distance = undefined));
    it('Should default to 5', () => {
      expect(
        filterNode()
          .find('select')
          .props().defaultValue
      ).to.eq(5);
    });
  });

  context('When choosing 2 miles', () => {
    it('should call the onChange method with 2', () => {
      const node = mount(
        <DistanceFilter distance={distance} onChange={onChange} />
      );
      node.find('select').simulate('change', { target: { value: 2 } });
      expect(onChange.calledWith(2)).to.eq(true);
    });
  });
});
