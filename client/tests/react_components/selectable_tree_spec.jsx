import React from 'react';
import { shallow } from 'enzyme';
import sinon from 'sinon';
import { expect } from 'chai';
import { describe, it } from 'mocha';
import SelectableTree from 'react_components/selectable_tree';
import { equal } from 'assert';

const options = [
  {
    key: 'public_charter',
    label: 'Public schools'
  },
  {
    key: 'public',
    label: 'District',
    parentKey: 'public_charter'
  },
  {
    key: 'charter',
    label: 'Charter',
    parentKey: 'public_charter'
  },
  {
    key: 'private',
    label: 'Private schools'
  }
];

describe('<SelectableTree/>', () => {
  it('renders all the options', () => {
    let renderedOptions = [];
    const wrapper = shallow(
      <SelectableTree options={options} activeOptions={[]} onChange={() => {}}>
        {opts => {
          renderedOptions = opts;
        }}
      </SelectableTree>
    );

    expect(renderedOptions.map(o => o.option.label).join(',')).to.equal(
      ['Public schools', 'District', 'Charter', 'Private schools'].join(',')
    );
  });

  it('when not noneMeansAll, renders all options as active when non active', () => {
    let renderedOptions = [];
    shallow(
      <SelectableTree options={options} activeOptions={[]} onChange={() => {}}>
        {opts => {
          renderedOptions = opts;
        }}
      </SelectableTree>
    );

    expect(renderedOptions.filter(o => o.active).length).to.eq(0);
  });

  it('when noneMeansAll, renders all options as active when non active', () => {
    let renderedOptions = [];
    shallow(
      <SelectableTree
        options={options}
        activeOptions={[]}
        onChange={() => {}}
        noneMeansAll
      >
        {opts => {
          renderedOptions = opts;
        }}
      </SelectableTree>
    );

    expect(
      renderedOptions
        .filter(o => o.active)
        .map(o => o.option.label)
        .join(',')
    ).to.equal(
      ['Public schools', 'District', 'Charter', 'Private schools'].join(',')
    );
  });

  it('correctly indicates whether an option is active', () => {
    let renderedOptions = [];
    const wrapper = shallow(
      <SelectableTree
        options={options}
        activeOptions={['charter']}
        onChange={() => {}}
      >
        {opts => {
          renderedOptions = opts;
        }}
      </SelectableTree>
    );

    expect(renderedOptions.find(o => o.option.key === 'charter').active).to.eq(
      true
    );
    expect(
      renderedOptions
        .filter(o => o.option.key !== 'charter')
        .some(o => o.active)
    ).to.equal(false);
  });

  describe('Invokes onChange with the correct options when option selected', () => {
    it('Selects descendants', () => {
      const onChange = sinon.spy();

      let renderedOptions = [];
      shallow(
        <SelectableTree
          options={options}
          activeOptions={[]}
          onChange={onChange}
        >
          {opts => {
            renderedOptions = opts;
          }}
        </SelectableTree>
      );

      const publicCharter = renderedOptions.find(
        o => o.option.key === 'public_charter'
      );
      publicCharter.select();

      expect(
        onChange.calledWith(['public_charter', 'public', 'charter'])
      ).to.eq(true);
    });

    it('Selects Ancestors', () => {
      const onChange = sinon.spy();

      let renderedOptions = [];
      shallow(
        <SelectableTree
          options={options}
          activeOptions={[]}
          onChange={onChange}
        >
          {opts => {
            renderedOptions = opts;
          }}
        </SelectableTree>
      );

      const charter = renderedOptions.find(o => o.option.key === 'charter');
      charter.select();

      expect(onChange.calledWith(['public_charter', 'charter'])).to.eq(true);
    });

    it('Leaves siblings selected', () => {
      const onChange = sinon.spy();

      let renderedOptions = [];
      shallow(
        <SelectableTree
          options={options}
          activeOptions={['private']}
          onChange={onChange}
        >
          {opts => {
            renderedOptions = opts;
          }}
        </SelectableTree>
      );

      const publicCharter = renderedOptions.find(
        o => o.option.key === 'charter'
      );
      publicCharter.select();

      expect(
        onChange.calledWith(['private', 'public_charter', 'charter'])
      ).to.eq(true);
    });

    it('Leaves siblings selected', () => {
      const onChange = sinon.spy();

      let renderedOptions = [];
      shallow(
        <SelectableTree
          options={options}
          activeOptions={['private']}
          onChange={onChange}
        >
          {opts => {
            renderedOptions = opts;
          }}
        </SelectableTree>
      );

      const charter = renderedOptions.find(o => o.option.key === 'charter');
      charter.select();

      expect(
        onChange.calledWith(['private', 'public_charter', 'charter'])
      ).to.eq(true);
    });
  });

  describe('Deselects the correct options', () => {
    it('Deselects ancestors if no children selected', () => {
      const onChange = sinon.spy();

      let renderedOptions = [];
      shallow(
        <SelectableTree
          options={options}
          activeOptions={['public_charter', 'charter']}
          onChange={onChange}
        >
          {opts => {
            renderedOptions = opts;
          }}
        </SelectableTree>
      );

      const charter = renderedOptions.find(o => o.option.key === 'charter');
      charter.select();
      expect(onChange.calledWith([])).to.eq(true);
    });

    it('Deselects children', () => {
      const onChange = sinon.spy();

      let renderedOptions = [];
      shallow(
        <SelectableTree
          options={options}
          activeOptions={['public_charter', 'public', 'charter']}
          onChange={onChange}
        >
          {opts => {
            renderedOptions = opts;
          }}
        </SelectableTree>
      );

      const publicCharter = renderedOptions.find(
        o => o.option.key === 'public_charter'
      );
      publicCharter.select();
      expect(onChange.calledWith([])).to.eq(true);
    });

    it('Leaves siblings selected', () => {
      const onChange = sinon.spy();

      let renderedOptions = [];
      shallow(
        <SelectableTree
          options={options}
          activeOptions={['public_charter', 'public', 'charter', 'private']}
          onChange={onChange}
        >
          {opts => {
            renderedOptions = opts;
          }}
        </SelectableTree>
      );

      const publicCharter = renderedOptions.find(
        o => o.option.key === 'public_charter'
      );
      publicCharter.select();
      expect(onChange.calledWith(['private'])).to.eq(true);
    });
  });
});
