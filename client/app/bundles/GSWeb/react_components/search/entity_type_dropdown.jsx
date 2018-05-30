import React from 'react';
import EntityTypeContext from './entity_type_context';
import CheckboxTree, { makeTree } from 'react_components/checkbox_tree';
import OpenableCloseable from 'react_components/openable_closeable';
import Checkbox from 'react_components/checkbox';
import CaptureOutsideClick from 'react_components/search/capture_outside_click';
import { capitalize } from 'util/i18n';

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

const calculateDropdownText = types => {
  const strings = [];
  // JT-6306
  if (types.indexOf('public') > -1 && types.indexOf('charter') > -1) {
    strings.push('public');
  } else if (types.indexOf('public') > -1) {
    strings.push('public district');
  } else if (types.indexOf('charter') > -1) {
    strings.push('public charter');
  }

  if (types.indexOf('private') > -1) {
    strings.push('private');
  }

  if (strings.length === 0) {
    strings.push('public');
    strings.push('private');
  }

  return capitalize(`${strings.join(' & ')} schools`);
};

const EntityTypeDropdown = () => (
  <EntityTypeContext.Consumer>
    {({ entityTypes, onEntityTypesChanged }) => (
      <OpenableCloseable>
        {(isOpen, { toggle, open, close } = {}) => (
          <CaptureOutsideClick callback={close}>
            <React.Fragment>
              <span className="label">Filter by:</span>
              <div className="dropdown entity-type-dropdown">
                <div
                  className="selection"
                  onClick={toggle}
                  onKeyPress={toggle}
                  role="button"
                  tabIndex={0}
                >
                  <div>
                    {calculateDropdownText(entityTypes)}
                    <span
                      className="icon-caret-down"
                      style={{ marginLeft: '8px' }}
                    />
                  </div>
                </div>
                {isOpen && (
                  <div className="panel">
                    <span className="checkbox-group">
                      <CheckboxTree
                        options={options}
                        activeOptions={entityTypes}
                        onChange={onEntityTypesChanged}
                      >
                        {opts =>
                          opts.map(({ option, active, select }) => (
                            <span
                              key={option.key}
                              onClick={select}
                              onKeyPress={select}
                              style={{
                                marginLeft: option.parentKey ? '20px' : ''
                              }}
                            >
                              <input
                                name={option.key}
                                type="checkbox"
                                value={option.value}
                                checked={active}
                              />
                              <label>{option.label}</label>
                            </span>
                          ))
                        }
                      </CheckboxTree>
                    </span>
                  </div>
                )}
              </div>
            </React.Fragment>
          </CaptureOutsideClick>
        )}
      </OpenableCloseable>
    )}
  </EntityTypeContext.Consumer>
);

export default EntityTypeDropdown;
