import React from 'react';
import PropTypes from 'prop-types';
import { connect } from 'react-redux';
import { Provider } from 'react-redux';
// import { selectSchool } from '../../actions/district_boundaries';
// import { bindActionCreators } from 'redux';
// import * as DistrictBoundaryActions from '../../actions/district_boundaries';
// import { getSchool, getSchools } from '../../reducers/district_boundaries_reducer';
// import DistrictBoundariesLegend from './district_boundaries_legend';
import SpinnyWheel from '../spinny_wheel';

class SchoolList extends React.Component {
  static defaultProps = {
    schools: [],
    className: ''
  }

  static propTypes = {
    schools: PropTypes.array.isRequired,
    school: PropTypes.object,
    selectSchool: PropTypes.func.isRequired,
    showMapView: PropTypes.func.isRequired,
    className: PropTypes.string
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
          <div>{school.address.street1}, {school.address.city}, {school.state}, {school.address.zip}</div>
          <div>{school.schoolType}, {school.gradeLevels} | {school.enrollment}</div>
          <div className="icon active icon-house"> <a href={this.homesForSaleHref(school)} target="_blank">Homes for sale</a></div>
        </span>
      </li>
    );
  }

  homesForSaleHref(entity) {
    let homesForSaleHref = null;
    homesForSaleHref = 'https://www.zillow.com/' + entity.state + '-' + entity.address.zip.split("-")[0] + '?cbpartner=Great+Schools&utm_source=GreatSchools&utm_medium=referral&utm_campaign=districtbrowsemap';
    return homesForSaleHref;
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
            {this.renderSchools()}
        </SpinnyWheel>
      </section>
    } else {
      return <section className={ 'school-list ' + this.props.className }>
        {this.renderSchools()}
      </section>
    }
  }
}

export default SchoolList;
