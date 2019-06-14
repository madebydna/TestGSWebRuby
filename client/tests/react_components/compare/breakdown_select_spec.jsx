import React from 'react';
import { mount, shallow } from 'enzyme';
import sinon from 'sinon';
import { expect } from 'chai';
import { before, describe, describe as context, it } from 'mocha';

import * as translation from 'util/i18n';
import BreakdownSelect from 'react_components/compare/breakdown_select';

describe('<BreakdownSelect />', () => {

    const breakdownSelect = () => {
        const outer = shallow(<BreakdownSelect breakdowns={['Hispanic', 'All students']} />);
        const Children = outer.prop('children');
        return mount(<Children breakdown='Hispanic' onBreakdownChanged={sinon.spy()}/>);
    }


    it('creates correct number of menu options', () => {
        expect(breakdownSelect().find('option')).to.have.lengthOf(2);
    })
    
    context('with Spanish as the current locale', () => {
        before(() => {
            translation.currentLocale = sinon.stub().returns('es');
            translation._setTranslationsHash({
                'breakdowns.Hispanic': 'Hispanos/Latinos',
                'breakdowns.All students': 'Todos los estudiantes'
            });
        });

        it('creates menu options with Spanish labels', () => {
            const select = breakdownSelect().find('select');
            expect(select.childAt(0).text()).to.equal('Hispanos/Latinos');
            expect(select.childAt(1).text()).to.equal('Todos los estudiantes');
        });

        it('creates menu options with correct values', () => {
            const select = breakdownSelect().find('select');
            expect(select.childAt(0).prop('value')).to.equal('Hispanic');
            expect(select.childAt(1).prop('value')).to.equal('All students');
        });
    });

    context('with English as the current locale', () => {
        before(() => {
            translation.currentLocale = sinon.stub().returns('es');
            translation._setTranslationsHash({
                'breakdowns.Hispanic': 'Hispanic',
                'breakdowns.All students': 'All students'
            });
        });

        it('creates menu options with English labels', () => {
            const select = breakdownSelect().find('select');
            expect(select.childAt(0).text()).to.equal('Hispanic');
            expect(select.childAt(1).text()).to.equal('All students');
        });
        
        it('creates menu options with correct values', () => {
            const select = breakdownSelect().find('select');
            expect(select.childAt(0).prop('value')).to.equal('Hispanic');
            expect(select.childAt(1).prop('value')).to.equal('All students');
        });
    });
    
});


