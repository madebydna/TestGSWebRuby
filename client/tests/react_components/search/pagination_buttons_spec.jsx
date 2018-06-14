/* eslint-disable no-return-assign */

import React from 'react';
import { mount, shallow } from 'enzyme';
import sinon from 'sinon';
import { expect } from 'chai';
import { before, describe, describe as context, it } from 'mocha';

import PaginationButtons from 'react_components/search/pagination_buttons';

describe('<PaginationButtons />', () => {
  const onPageChanged = () => {};
  let page = null;
  let totalPages = null;
  const buttonsNode = () =>
    mount(
      <PaginationButtons
        page={page}
        totalPages={totalPages}
        onPageChanged={onPageChanged}
      />
    );
  const buttons = () => buttonsNode().find('[role="button"]');
  const activeButton = () => buttonsNode().find('.active');

  context('when there is 1 total pages', () => {
    before(() => (totalPages = 1));

    context('and we are on page 1', () => {
      before(() => (page = 1));

      it('shows back forward buttons, and page 1', () => {
        expect(buttons().length).to.eq(3);
      });

      it('should have correct sequence of page numbers', () => {
        expect(buttons().map(b => b.text())).to.eql(['', '1', '']);
      });
    });
  });

  context('when there are 2 total pages', () => {
    before(() => (totalPages = 2));

    context('and we are on page 1', () => {
      before(() => (page = 1));

      it('should not be able to go to previous page', () => {
        expect(
          buttons()
            .at(0)
            .parent()
            .prop('enabled')
        ).to.eq(false);
      });

      it('should be able to go to next page', () => {
        expect(
          buttons()
            .at(3)
            .parent()
            .prop('enabled')
        ).to.eq(true);
      });

      it('should have correct sequence of page numbers', () => {
        expect(buttons().map(b => b.text())).to.eql(['', '1', '2', '']);
      });

      it('page 1 should be active', () => {
        expect(activeButton().text()).to.eq('1');
      });

      it('2nd button should be active', () => {
        expect(
          buttons()
            .at(1)
            .hasClass('active')
        ).to.eq(true);
      });
    });

    context('and we are on page 2', () => {
      before(() => (page = 2));

      it('it shows 4 buttons', () => {
        expect(buttons().length).to.eq(4);
      });

      it('page 2 should be active', () => {
        expect(activeButton().text()).to.eq('2');
      });

      it('3rd button should be active', () => {
        expect(
          buttons()
            .at(2)
            .hasClass('active')
        ).to.eq(true);
      });
    });
  });

  context('when there are 10 total pages', () => {
    before(() => (totalPages = 10));

    context('and we are on page 1', () => {
      before(() => (page = 1));

      it('should not be able to go to previous page', () => {
        expect(
          buttons()
            .at(0)
            .parent()
            .prop('enabled')
        ).to.eq(false);
      });

      it('should be able to go to next page', () => {
        expect(
          buttons()
            .at(3)
            .parent()
            .prop('enabled')
        ).to.eq(true);
      });

      it('it shows 9 buttons', () => {
        expect(buttons().length).to.eq(9);
      });

      it('page 1 should be active', () => {
        expect(activeButton().text()).to.eq('1');
      });

      it('2nd button should be active', () => {
        expect(
          buttons()
            .at(1)
            .hasClass('active')
        ).to.eq(true);
      });

      it('should have correct sequence of page numbers', () => {
        expect(buttons().map(b => b.text())).to.eql([
          '',
          '1',
          '2',
          '3',
          '4',
          '5',
          '6',
          '7',
          ''
        ]);
      });
    });

    context('and we are on page 10', () => {
      before(() => (page = 10));

      it('it shows 9 buttons', () => {
        expect(buttons().length).to.eq(9);
      });

      it('should have correct sequence of page numbers', () => {
        expect(buttons().map(b => b.text())).to.eql([
          '',
          '4',
          '5',
          '6',
          '7',
          '8',
          '9',
          '10',
          ''
        ]);
      });
    });
  });
});
