import React from 'react';
import PropTypes from 'prop-types';
import Account from './account';
import { getCurrentSession } from 'api_clients/session';

class AccountContext extends React.Component {
  static propTypes = {};
  static defaultProps = {};

  constructor(props) {
    super(props);
    this.state = {};
  }

  componentDidMount() {
    this.retrieveSession();
  }

  retrieveSession() {
    getCurrentSession().done(currentUser => {
      this.setState({
        currentUser
      });
    });
  }

  render() {
    return this.state.currentUser ? (
      <Account
        currentUser={this.state.currentUser}
        ospDashboardUrl="/official-school-profile/dashboard.page"
        stateLocale="en"
        cityLocale="en"
        mySchoolListUrl="/my-school-list/"
        changePasswordUrl="/account/password/"
      />
    ) : null;
  }
}

export default AccountContext;
