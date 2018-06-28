import React from 'react';
import Dropdownable from 'react_components/dropdownable';
import CaptureOutsideClick from './capture_outside_click';

const Dropdown = props => (
  <Dropdownable {...props}>
    {({ isOpen, open, close, toggle, selection, options }) => (
      <CaptureOutsideClick callback={close}>
        <div className="dropdown">
          <div
            className="selection"
            onClick={toggle}
            onKeyPress={toggle}
            role="button"
            tabIndex={0}
          >
            <div>
              {selection.label}
              <span
                className={`icon-caret-down ${isOpen ? 'rotate-text-180' : ''}`}
                style={{ marginLeft: '8px' }}
              />
            </div>
          </div>
          {isOpen && (
            <div className="panel">
              {options.map(({ option, select, active }) => (
                <div
                  onClick={select}
                  onKeyPress={select}
                  role="radio"
                  aria-checked={active}
                >
                  <span>{option.label}</span>
                  {active && (
                    <span
                      className="icon-checkmark"
                      style={{ marginLeft: '8px' }}
                    />
                  )}
                </div>
              ))}
            </div>
          )}
        </div>
      </CaptureOutsideClick>
    )}
  </Dropdownable>
);

export default Dropdown;
