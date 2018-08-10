import React from 'react';
import PropTypes from 'prop-types';
import CaptureOutsideClick from 'react_components/search/capture_outside_click';
import OpenableCloseable from 'react_components/openable_closeable';

class Modal extends React.Component {
  static propTypes = {
    children: PropTypes.func,
    renderTrigger: PropTypes.func,
    closeOnOutsideClick: PropTypes.bool,
    className: PropTypes.string
  };

  static defaultProps = {
    closeOnOutsideClick: true,
    renderTrigger: () => {},
    children: () => {},
    className: ''
  };

  overlay = () => (
    <div
      className="remodal-overlay remodal-is-opened"
      style={{ display: 'block' }}
    />
  );

  wrapperProps = isOpen => ({
    className: isOpen ? 'remodal-wrapper remodal-is-opened' : null,
    style: { display: isOpen ? 'block' : 'none' }
  });

  modalProps = () => ({
    className: 'remodal modal_info_box remodal-is-initialized remodal-is-opened'
  });

  render() {
    return (
      <OpenableCloseable>
        {(isOpen, { openForDuration, open, close, toggle, remainingTime }) => (
          <React.Fragment>
            {this.props.renderTrigger(isOpen, {
              openForDuration,
              open,
              close,
              toggle
            })}
            <div className={this.props.className}>
              {isOpen ? this.overlay() : null}
              <div {...this.wrapperProps(isOpen)}>
                <CaptureOutsideClick
                  callback={this.props.closeOnOutsideClick ? close : () => {}}
                >
                  <div {...this.modalProps()}>
                    <button
                      data-remodal-action="close"
                      className="remodal-close"
                      onClick={close}
                    />
                    <div className="remodal-content">
                      {this.props.children({
                        openForDuration,
                        close,
                        remainingTime
                      })}
                    </div>
                  </div>
                </CaptureOutsideClick>
              </div>
            </div>
          </React.Fragment>
        )}
      </OpenableCloseable>
    );
  }
}

export default Modal;
