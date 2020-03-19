import React from 'react';
import { getCurrentSession } from 'api_clients/session';
import Account from './account';

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
    getCurrentSession({
      fields: [
        'email',
        'firstName',
        'schoolUsers',
        'mightHaveOsps',
      ]
    }).done(currentUser => {
      this.setState({
        currentUser
      });
    });
  }

  render() {
    return this.state.currentUser ? (
      <Account mySchoolListUrl="/my-school-list/" {...this.state.currentUser} />
    ) : null;
  }
}

export default AccountContext;
