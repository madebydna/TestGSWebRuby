import React from 'react';
import PropTypes from 'prop-types';
import EmailSettings from './email_settings';
import OpenableCloseable from 'react_components/openable_closeable';
import ChangePasswordForm from './change_password_form';
import GradeLevelCheckboxes from './grade_level_checkboxes';

const Account = ({ currentUser, ospDashboardUrl, mySchoolListUrl }) => (
  <div
    style={{
      maxWidth: '1200px',
      marginLeft: 'auto',
      marginRight: 'auto'
    }}
  >
    <div className="mvl">
      <div className="row limit-width-1200 ">
        <div className="col-xs-12 clearfix phm">
          <div className="fr font-size-large mam notranslate">
            {currentUser.firstName}
          </div>
        </div>
      </div>
    </div>

    {(true ||
      currentUser.provisionalOrApprovedOspUser ||
      currentUser.isEspSuperuser) && (
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

    <div>
      <div className="drawer">
        <div className="heading">
          <span>My Profile</span>
          <span className="icon i-32-open-arrow-head" />
        </div>
      </div>
      <div className="body">
        Tell us a little more about yourself so we can send you updates about
        your community. This information will not be displayed publicly on the
        site.
        <div className="grade-level-checkboxes">
          <br />
          <div className="open-sans_sb">
            What grade levels are you interested in?
          </div>
          <br />
          <GradeLevelCheckboxes grades={currentUser.studentGradeLevels} />
        </div>
      </div>
    </div>

    <div className="drawer">
      <a href={mySchoolListUrl} className="heading">
        My School List
      </a>
    </div>

    <div>
      <OpenableCloseable>
        {(isOpen, { toggle }) => (
          <React.Fragment>
            <div className="drawer">
              <div className="heading" onClick={toggle}>
                <span>Email Subscriptions</span>
                <span
                  className={`icon i-32-${
                    isOpen ? 'open' : 'close'
                  }-arrow-head`}
                />
              </div>
            </div>
            {isOpen && (
              <EmailSettings userSubscriptions={currentUser.subscriptions} />
            )}
          </React.Fragment>
        )}
      </OpenableCloseable>
    </div>

    <div>
      <OpenableCloseable>
        {(isOpen, { toggle }) => (
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
              <div className="body">{isOpen && <ChangePasswordForm />}</div>
            </div>
          </React.Fragment>
        )}
      </OpenableCloseable>
    </div>
  </div>
);

export default Account;
