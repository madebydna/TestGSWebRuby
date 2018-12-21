import React from 'react';
import { shallow, mount } from 'enzyme';
import { expect } from 'chai';
import sinon from 'sinon';
import { describe, describe as context, it } from 'mocha';

import Toc from 'react_components/community/toc';
import TocItem from 'react_components/community/toc_item';
import * as scrolling from 'util/scrolling';

describe('<Toc/>', () => {
  const foo = {
    key: 'foo',
    label: 'foo',
    anchor: '#foo',
    selected: true
  }
  const baz = {
    key: 'baz',
    label: 'baz',
    anchor: '#baz',
    selected: false
  }
  const bar = {
    key: 'bar',
    label: 'bar',
    anchor: '#bar',
    selected: false
  }
  const toc = mount(<Toc tocItems={[foo, baz, bar]}/>);

  context('should render TocItems', () => {
    it('should contain a TocItem in the component', () => (
      expect(toc.containsMatchingElement(<TocItem />))
    ))

    it('should render 3 TocItems', () => (
      expect(toc.find(TocItem)).to.have.length(3)
    ))
  })

  context('selected TocItem should change on button press', ()=>{
    it('should have foo selected', () => {
      expect(toc.find('.selected').text()).to.equal('Foo');
    })

    it('should change to bar when selected', () => {
      const tocItem = toc.find(TocItem).at(2);
      const scrollToElement = sinon.stub(scrolling, 'scrollToElement');
      tocItem.find('li').simulate('click');
      expect(scrollToElement.calledOnce).to.be.true;
      expect(toc.find(TocItem).at(2).prop('selected')).to.equal(true);
      expect(toc.find(TocItem).at(1).prop('selected')).to.equal(false);
    })
  })
});