import React from 'react';
import { mount } from 'enzyme';
import sinon from 'sinon';
import { expect } from 'chai';
import { before, describe, describe as context, it } from 'mocha';

import ButtonGroup from 'react_components/buttongroup';

describe('<ButtonGroup />', () => {
  let activeOption = '';
  let multiple;
  let label;
  let allowDeselect;
  const onSelect = sinon.spy();
  const options = [
    { key: 'e', label: 'Elementary' },
    { key: 'm', label: 'Middle' },
    { key: 'h', label: 'High' },
    { key: 'p', label: 'Preschool' }
  ];
  const buttonGroup = () =>
    mount(
      <ButtonGroup
        options={options}
        onSelect={onSelect}
        activeOption={activeOption}
        multiple={multiple}
        label={label}
        allowDeselect={allowDeselect}
      />
    );

  afterEach(() => onSelect.reset());

  context('With four options', () => {
    it('Expect four buttons', () =>
      expect(buttonGroup().find('button').length).to.eq(4));

    context('With elementary selected', () => {
      before(() => (activeOption = 'e'));

      it('Expect elementary to be selected', () => {
        const activeButton = buttonGroup().find('button.active');
        expect(activeButton.length).to.eq(1);
        expect(activeButton.text()).to.eq('Elementary');
      });

      context('With allowDeselect false', () => {
        before(() => (allowDeselect = false));

        context('When trying to click on elementary', () => {
          it('Nothing happens', () => {
            buttonGroup()
              .find('button.active')
              .simulate('click');
            expect(onSelect.calledOnce).to.be.false;
          });
        });

        context('When trying to click on middle', () => {
          it('Triggers onSelect', () => {
            buttonGroup()
              .find('button')
              .not('.active')
              .first()
              .simulate('click');
            expect(onSelect.calledOnce).to.be.true;
          });
        });
      });

      context('With allowDeselect true', () => {
        before(() => (allowDeselect = true));

        context('When trying to click on elementary', () => {
          it('Triggers onSelect', () => {
            buttonGroup()
              .find('button.active')
              .simulate('click');
            expect(onSelect.calledOnce).to.be.true;
          });
        });

        context('When trying to click on middle', () => {
          it('Triggers onSelect', () => {
            buttonGroup()
              .find('button')
              .not('.active')
              .first()
              .simulate('click');
            expect(onSelect.calledOnce).to.be.true;
          });
        });
      });

      context('With multiple true', () => {
        before(() => (multiple = true));

        context('When clicking on middle', () => {
          it('should call the onSelect function with both e and m', () => {
            buttonGroup()
              .find('button')
              .not('.active')
              .first()
              .simulate('click');
            expect(onSelect.calledWith(['e', 'm'])).to.be.true;
          });
        });
      });

      context('With multiple false', () => {
        before(() => (multiple = false));

        context('When clicking on middle', () => {
          it('should call the onSelect function with just m', () => {
            buttonGroup()
              .find('button')
              .not('.active')
              .first()
              .simulate('click');
            expect(onSelect.calledWith(['e', 'm'])).to.be.false;
            expect(onSelect.calledWith('m')).to.be.true;
          });
        });
      });
    });

    context('With elementary and middle selected', () => {
      before(() => (activeOption = ['e', 'm']));

      it('Expect elementary and middle to be selected', () => {
        const activeButton = buttonGroup().find('button.active');
        expect(activeButton.length).to.eq(2);
        expect(activeButton.map(node => node.text())).to.include('Elementary');
        expect(activeButton.map(node => node.text())).to.include('Middle');
        expect(activeButton.map(node => node.text())).to.not.include('High');
      });
    });

    context('When choosing elementary', () => {
      before(() => (activeOption = ''));

      it("should call the onSelect function with 'e'", () => {
        buttonGroup()
          .find('button')
          .first()
          .simulate('click');
        expect(onSelect.calledWith('e')).to.be.true;
      });
    });

    context('With garbage selected', () => {
      before(() => (activeOption = 'Private'));

      it('Expect nothing to be selected', () => {
        const activeButton = buttonGroup().find('button.active');
        expect(activeButton.length).to.eq(0);
      });
    });
  });
});
