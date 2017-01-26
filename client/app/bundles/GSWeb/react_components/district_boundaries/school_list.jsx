import React, { PropTypes } from 'react';
import { connect } from 'react-redux';
import { Provider } from 'react-redux';
import { selectSchool } from '../../actions/district_boundaries';
import { bindActionCreators } from 'redux';
import * as DistrictBoundaryActions from '../../actions/district_boundaries';

class SchoolList extends React.Component {
  static defaultProps = {
    schools: []
  }

  static propTypes = {
    schools: React.PropTypes.array.isRequired,
    school: React.PropTypes.object,
    selectSchool: React.PropTypes.func.isRequired
  }

  onClickSchool(school) {
    return () => this.props.selectSchool(school.id, school.state);
  }

  renderRating(rating) {
    let className = 'circle-rating--small circle-rating--' + rating;
    return <div className={className}>
      {rating}
      <span className="rating-circle-small">/10</span>
    </div>;
  }

  renderSchool(school) {
    let liClass = '';
    if(this.props.school && this.props.school.state == school.state && this.props.school.id == school.id) {
      liClass = 'selected';
    }
    return (
      <li
        key={school.state + school.id}
        onClick={this.onClickSchool(school)}
        className={liClass} >
        { school.rating && 
          <div className="school-rating">
            {this.renderRating(school.rating)}
          </div>
        }
        <div className="school">
          {school.name}
        </div>
      </li>
    );
  }

  renderSchools() {
    return <ol>
      {this.props.schools.map(s => this.renderSchool(s))}
    </ol>
  }

  render() {
    return(
      <section>
        <h3>Schools in district</h3>
        {this.renderSchools()}
      </section>
    );
  }
}

export default connect(
  state => ({
    school: state.districtBoundaries.school,
    schools: Object.values(state.districtBoundaries.schools)
  }),
  dispatch => bindActionCreators(DistrictBoundaryActions, dispatch)
)(SchoolList);
