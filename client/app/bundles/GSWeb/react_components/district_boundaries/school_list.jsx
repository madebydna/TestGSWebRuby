import React from 'react';
import PropTypes from 'prop-types';
import { capitalize, t } from 'util/i18n';
import { connect } from 'react-redux';
import { Provider } from 'react-redux';
import { selectSchool } from '../../actions/district_boundaries';
import { bindActionCreators } from 'redux';
import * as DistrictBoundaryActions from '../../actions/district_boundaries';
import {
  getSchool,
  getSchools
} from '../../reducers/district_boundaries_reducer';
import DistrictBoundariesLegend from './district_boundaries_legend';
import SpinnyWheel from '../spinny_wheel';
import { getHomesForSaleHref } from '../../util/school';
import BrownOwl from '../icons/brown_owl';

class SchoolList extends React.Component {
  static defaultProps = {
    schools: [],
    className: ''
  };

  static propTypes = {
    schools: PropTypes.array.isRequired,
    school: PropTypes.object,
    selectSchool: PropTypes.func.isRequired,
    showMapView: PropTypes.func.isRequired,
    className: PropTypes.string
  };

  onClickSchool(school) {
    return () => {
      this.props.selectSchool(school.id, school.state);
      this.props.showMapView();
      try {
        window.open(school.links.profile);
      } catch (e) {}
    };
  }

  onClickMap(school) {
    return event => {
      this.props.selectSchool(school.id, school.state);
      this.props.showMapView();
      event.stopPropagation();
      return false;
    };
  }

  renderRating(rating) {
    if (!rating) {
      return (
        <BrownOwl />
      );
    }
    const className = `circle-rating--small circle-rating--${  rating}`;
    return (
      <div className={className}>
        {rating}
        <span className="rating-circle-small">/10</span>
      </div>
    );
  }

  renderSchool(school) {
    let liClass = '';
    if (
      this.props.school &&
      this.props.school.state == school.state &&
      this.props.school.id == school.id
    ) {
      liClass = 'active';
    }
    const utmCampaignCode = 'districtbrowsemap';
    const homesForSaleHref = getHomesForSaleHref(school.state, school.address, utmCampaignCode);
    return (
      <li key={school.state + school.id} className={liClass}>
        <span>{this.renderRating(school.rating)}</span>
        <span>
          <a href={school.links.profile} className="name">
            {school.name}
          </a>
          <br />
          <div className="district-boundary-school-links">
            <a
              href="javascript:void(0);"
              onClick={this.onClickMap(school)}
              className="view-school-in-map-link"
            >
              <span className="icon icon-location active" />{t('view_in_map')}
            </a>
            {homesForSaleHref && (
              <a
                href={homesForSaleHref}
                target="_blank"
                className="homes-for-sale-link"
              >
                <span className="homes-for-sale">
                  <span key="homes-for-sale" className="icon icon-house active" />
                    {t('homes_for_sale')}
                </span>
              </a>
            )}
          </div>
        </span>
      </li>
    );
  }

  renderSchools() {
    return <ol>{this.props.schools.map(s => this.renderSchool(s))}</ol>;
  }

  render() {
    if (this.props.loading) {
      return (
        <section className={`school-list ${  this.props.className}`}>
          <SpinnyWheel>
            <h3>{t('schools_in_district')}</h3>
            {this.renderSchools()}
          </SpinnyWheel>
        </section>
      );
    }
      return (
        <section className={`school-list ${  this.props.className}`}>
          <h3>{t('schools_in_district')}</h3>
          {this.renderSchools()}
        </section>
      );

  }
}

export default connect(
  state => ({
    schools: getSchools(state.districtBoundaries).sort(
      (s1, s2) => (s2.rating || 0) - (s1.rating || 0)
    ),
    school: getSchool(state.districtBoundaries),
    loading: state.districtBoundaries.loading
  }),
  dispatch => bindActionCreators(DistrictBoundaryActions, dispatch)
)(SchoolList);
