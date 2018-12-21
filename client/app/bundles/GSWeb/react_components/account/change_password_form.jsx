import React from 'react';
import { changePassword } from 'api_clients/session';

class ChangePasswordForm extends React.Component {
  static propTypes = {};
  static defaultProps = {};

  constructor(props) {
    super(props);
    this.state = {
      password: null,
      confirmPassword: null
    };
    this.submitChangePasswordRequest = this.submitChangePasswordRequest.bind(
      this
    );
  }

  setFieldFunc(field) {
    return e =>
      this.setState({ [field]: e.target.value }, () => {
        if (this.state.error) {
          this.validateForm();
        }
      });
  }

  validateForm(callback) {
    if (!this.state.password || this.state.password.length === 0) {
      this.setState({ error: 'Please specify a new password' }, callback);
    } else if (this.state.password !== this.state.confirmPassword) {
      this.setState({ error: 'The passwords do not match' }, callback);
    } else {
      this.setState({ error: null }, callback);
    }
  }

  submitChangePasswordRequest() {
    this.validateForm(() => {
      if (!this.state.error) {
        changePassword(this.state.password)
          .done(result => {
            if (result.success) {
              this.setState({ successMessage: result.message });
            } else {
              this.setState({ error: result.message });
            }
          })
          .fail(() => {
            this.setState({ error: 'An unexpected error occured' });
          });
      }
    });
  }

  render() {
    return (
      <div className="limit-width-1200 mtl">
        <div className="row phm">
          <div className="col-sm-12">
            <form action="#" onSubmit={e => e.preventDefault()}>
              <input type="hidden" name="_method" value="PUT" />
              <div className="modal-body">
                {this.state.successMessage ? (
                  this.state.successMessage
                ) : (
                  <div>
                    <div className="form-group">
                      <br />
                      <label className="control-label" htmlFor="password">
                        New password
                      </label>
                      <div className="controls">
                        <input
                          type="password"
                          id="new_password"
                          name="new_password"
                          placeholder=""
                          className="input-xlarge"
                          style={{ width: '100%' }}
                          onChange={this.setFieldFunc('password')}
                        />
                      </div>
                      <br />
                      <label className="control-label" htmlFor="password">
                        Confirm your new password
                      </label>
                      <div className="controls">
                        <input
                          type="password"
                          id="confirm_password"
                          name="confirm_password"
                          placeholder=""
                          className="input-xlarge"
                          style={{ width: '100%' }}
                          onChange={this.setFieldFunc('confirmPassword')}
                        />
                      </div>
                    </div>
                    <div style={{ color: 'red', display: 'block' }}>
                      {this.state.error}
                    </div>
                    <div className="controls clearfix">
                      <br />
                      <button
                        type="button"
                        className="btn btn-primary fr"
                        onClick={this.submitChangePasswordRequest}
                      >
                        Submit
                      </button>
                    </div>
                  </div>
                )}
              </div>
            </form>
          </div>
        </div>
      </div>
    );
  }
}

export default ChangePasswordForm;
