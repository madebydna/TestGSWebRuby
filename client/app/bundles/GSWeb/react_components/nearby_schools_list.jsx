import React from 'react';
import PropTypes from 'prop-types';
import NearbySchool from './nearby_school';
import SpinnyWheel from './spinny_wheel';
import { t, capitalize } from '../util/i18n';

class NearbySchoolsList extends React.Component {
  static propTypes = {
    visible: PropTypes.bool.isRequired,
    school: PropTypes.shape({
      state: PropTypes.string,
      id: PropTypes.number
    }).isRequired,
    schools: PropTypes.array,
    allSchoolsLoaded: PropTypes.bool.isRequired,
    nearbySchoolsType: PropTypes.string.isRequired,
    getSchools: PropTypes.func.isRequired
  };

  constructor(props) {
    super(props);
    this.state = {
      offset: 0
    };
    this.pageLeft = this.pageLeft.bind(this);
    this.pageRight = this.pageRight.bind(this);
    this.trackPagination = this.trackPagination.bind(this);
    this.pageSize = 3;
  }

  requestSchools(count) {
    if (this.props.allSchoolsLoaded) {
      return;
    }
    this.props.getSchools(
      this.props.school.state,
      this.props.school.id,
      (this.props.schools || []).length,
      count || this.pageSize
    );
  }

  getInitialSchools() {
    this.requestSchools(6);
  }

  componentDidMount(nextProps) {
    if (this.props.schools === undefined) {
      this.getInitialSchools();
    }
  }

  trackPagination(label) {
    window.analyticsEvent('Profile', this.props.nearbySchoolsType, label);
  }

  visibleSchools() {
    return this.props.schools.slice(
      this.state.offset,
      this.state.offset + this.pageSize
    );
  }

  renderNearbySchools() {
    return this.visibleSchools().map((school, i) => (
      <NearbySchool
        key={i}
        GSRating={school.gs_rating}
        averageRating={school.average_rating}
        schoolName={school.name}
        schoolType={t(`school_types.${capitalize(school.type)}`)}
        gradeRange={school.level}
        city={school.city}
        state={school.state}
        distance={school.distance}
        schoolUrl={school.links.show}
        nearbySchoolsType={this.props.nearbySchoolsType}
      />
    ));
  }

  pageLeft() {
    this.setState({
      offset: this.state.offset - this.pageSize
    });
    this.trackPagination('Previous');
  }

  pageRight() {
    if (this.onPenultimateOrLastPage()) {
      this.requestSchools();
    }
    this.setState({
      offset: this.state.offset + this.pageSize
    });
    this.trackPagination('Next');
  }

  // true if on 2nd-to-last OR last page
  onPenultimateOrLastPage() {
    return this.state.offset >= this.props.schools.length - 2 * this.pageSize;
  }

  shouldGetMoreSchools() {
    return (
      this.props.schools !== undefined &&
      this.state.offset + this.pageSize >=
        this.props.schools.length - this.pageSize
    );
  }

  canPageLeft() {
    return this.state.offset >= this.pageSize;
  }

  canPageRight() {
    return this.state.offset + this.pageSize < this.props.schools.length;
  }

  pageLeftButton() {
    let className = '';
    let onClick;
    if (this.canPageLeft()) {
      className = 'active';
      onClick = this.pageLeft;
    }
    return (
      <div className={`prev ${className}`} onClick={onClick}>
        <div className="icon-chevron-right flip-horizontally" />
      </div>
    );
  }

  pageRightButton() {
    let className = '';
    let onClick;
    if (this.canPageRight()) {
      className = 'active';
      onClick = this.pageRight;
    }
    return (
      <div className={`next ${className}`} onClick={onClick}>
        <div className="icon-chevron-right" />
      </div>
    );
  }

  renderSpinny() {
    const content = (
      <div style={{ height: '80px', width: '100%', display: 'block' }} />
    );
    return (
      <div>
        <SpinnyWheel content={content} />
      </div>
    );
  }

  waitingForInitialSchools() {
    return this.props.schools === undefined;
  }

  noSchoolsFound() {
    return this.props.allSchoolsLoaded && this.props.schools.length === 0;
  }

  render() {
    if (this.waitingForInitialSchools()) {
      return this.renderSpinny();
    } else if (this.noSchoolsFound()) {
      return <div style={{ 'text-align': 'center' }}>No schools found</div>;
    }
    return (
      <div className="slider">
        {this.pageLeftButton()}
        <div className="slider-body">{this.renderNearbySchools()}</div>
        {this.pageRightButton()}
      </div>
    );
  }
}

export default NearbySchoolsList;
