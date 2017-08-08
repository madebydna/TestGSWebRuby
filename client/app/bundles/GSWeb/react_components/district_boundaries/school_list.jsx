import React, { PropTypes } from 'react';
import { connect } from 'react-redux';
import { Provider } from 'react-redux';
import { selectSchool } from '../../actions/district_boundaries';
import { bindActionCreators } from 'redux';
import * as DistrictBoundaryActions from '../../actions/district_boundaries';
import { getSchool, getSchools } from '../../reducers/district_boundaries_reducer';
import DistrictBoundariesLegend from './district_boundaries_legend';
import SpinnyWheel from '../spinny_wheel';

class SchoolList extends React.Component {
  static defaultProps = {
    schools: [],
    className: ''
  }

  static propTypes = {
    schools: React.PropTypes.array.isRequired,
    school: React.PropTypes.object,
    selectSchool: React.PropTypes.func.isRequired,
    showMapView: React.PropTypes.func.isRequired,
    className: React.PropTypes.string
  }

  onClickSchool(school) {
    return () => {
      this.props.selectSchool(school.id, school.state);
      this.props.showMapView();
      try {
        window.open(school.links.profile);
      } catch (e) {}
    }
  }

  onClickMap(school) {
    return (event) => {
      this.props.selectSchool(school.id, school.state);
      this.props.showMapView();
      event.stopPropagation();
      return false;
    }
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
      liClass = 'active';
    }
    return (
      <li key={school.state + school.id} className={liClass} >
        { school.rating && <span>{this.renderRating(school.rating)}</span> }
        <span>
          <a href={school.links.profile} className="name" target="_blank">{school.name}</a>
          <br/>
          <a href="javascript:void(0);" onClick={this.onClickMap(school)}><span className="icon icon-location active"/>View in map</a>
        </span>
      </li>
    );
  }

  renderSchools() {
    return <ol>
      {this.props.schools.map(s => this.renderSchool(s))}
    </ol>
  }

  render() {
    if(this.props.loading) {
      return <section className={ 'school-list ' + this.props.className }>
        <SpinnyWheel>
          <h3>Schools in district</h3>
            {this.renderSchools()}
        </SpinnyWheel>
      </section>
    } else {
      return <section className={ 'school-list ' + this.props.className }>
        <h3>Schools in district</h3>
        {this.renderSchools()}
      </section>
    }
  }
}

export default connect(
  state => ({
    schools: getSchools(state.districtBoundaries).sort((s1,s2) => (s2.rating || 0) - (s1.rating || 0)),
    school: getSchool(state.districtBoundaries),
    loading: state.districtBoundaries.loading
  }),
  dispatch => bindActionCreators(DistrictBoundaryActions, dispatch)
)(SchoolList);
