import React from 'react';
import PropTypes from 'prop-types';
import withViewportSize from 'react_components/with_viewport_size';
import OpenableCloseable from 'react_components/openable_closeable';
import SearchBox from 'react_components/search_box';
import { validSizes as validViewportSizes } from 'util/viewport';
// import EmailSettings from './email_settings';
import ChangePasswordForm from './change_password_form';
// import GradeLevelCheckboxes from './grade_level_checkboxes';

const ospDashboardUrl = '/official-school-profile/dashboard/';
const mySchoolListUrl = '/my-school-list/';
const myEmailPreferencesUrl = '/preferences/';

const Account = ({
  size,
  email,
  firstName,
  mightHaveOsps,
  studentGradeLevels,
  subscriptions
}) => (
  <div
    style={{
      maxWidth: '1200px',
      marginLeft: 'auto',
      marginRight: 'auto'
    }}
  >
    <SearchBox size={size} />
    <div className="mvl">
      <div className="row limit-width-1200 ">
        <div className="col-xs-12 clearfix phm">
          <div className="fr mam" style={{ fontSize: '18px' }}>
            {firstName || email}
          </div>
        </div>
      </div>
    </div>
    <div>
      <OpenableCloseable>
        {(isOpen, {toggle}) => (
            <React.Fragment>
              <div className="drawer">
                <div className="heading" onClick={toggle}>
                  <span>Change Password</span>
                  <span
                      className={`icon i-32-${
                          isOpen ? 'open' : 'close'
                      }-arrow-head`}
                  />
                </div>
                <div className="body">{isOpen && <ChangePasswordForm/>}</div>
              </div>
            </React.Fragment>
        )}
      </OpenableCloseable>
    </div>
    {mightHaveOsps && (
      <div>
        <div className="drawer">
          <div className="heading">
            <span>Edit School Profile</span>
            <span className="icon i-32-open-arrow-head" />
          </div>
          <div className="body">
            <div className="tac">
              <img
                src="/assets/account_management/school_icon.png"
                alt="Official School Profile"
              />
            </div>
            <div className="pbm tac font-size-large">
              Keep your school profiles up to date
            </div>
            <div className="tac">
              <a href={ospDashboardUrl} className="ptm">
                <button className="btn btn-primary">Edit School Profile</button>
              </a>
            </div>
          </div>
        </div>
      </div>
    )}

    <div className="drawer">
      <a href={myEmailPreferencesUrl} className="heading">
        Email Preferences
      </a>
    </div>

    <div className="drawer">
      <a href={mySchoolListUrl} className="heading">
        My School List
      </a>
    </div>

  </div>
);

Account.propTypes = {
  size: PropTypes.oneOf(validViewportSizes).isRequired,
  email: PropTypes.string.isRequired,
  firstName: PropTypes.string,
  mightHaveOsps: PropTypes.bool.isRequired,
  studentGradeLevels: PropTypes.arrayOf(PropTypes.string),
  subscriptions: PropTypes.arrayOf(PropTypes.object)
};

Account.defaultProps = {
  firstName: null,
  studentGradeLevels: [],
  subscriptions: []
};

export default withViewportSize({ propName: 'size' })(Account);
