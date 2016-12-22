import React, { PropTypes } from 'react';
import NearbySchool from './nearby_school';
import SpinnyWheel from './spinny_wheel';

class NearbySchoolsList extends React.Component {

  static propTypes = {
    visible: React.PropTypes.bool.isRequired,
    school: React.PropTypes.shape({
      state: React.PropTypes.string,
      id: React.PropTypes.number
    }).isRequired,
    schools: React.PropTypes.array,
    allSchoolsLoaded: React.PropTypes.bool.isRequired,
    nearbySchoolsType: React.PropTypes.string.isRequired,
    getSchools: React.PropTypes.func.isRequired
  };

  constructor(props) {
    super(props);
    this.state = {
      offset: 0
    }
    this.pageLeft = this.pageLeft.bind(this);
    this.pageRight = this.pageRight.bind(this);
    this.trackPagination = this.trackPagination.bind(this);
    this.pageSize = 3;
  }

  requestSchools(count) {
    if(this.props.allSchoolsLoaded) {
      return;
    }
    this.props.getSchools(
      this.props.school.state,
      this.props.school.id,
      (this.props.schools || []).length,
      (count || this.pageSize)
    );
  }

  getInitialSchools() {
    this.requestSchools(6);
  }

  componentDidMount(nextProps) {
    if(this.props.schools === undefined) {
      this.getInitialSchools();
    }
  }

  trackPagination(label) {
    window.analyticsEvent('Profile', this.props.nearbySchoolsType, label);
  }

  visibleSchools() {
    return this.props.schools.slice(this.state.offset, this.state.offset + this.pageSize);
  }

  renderNearbySchools() {
    return this.visibleSchools().map(function(school,i) {
      return (<NearbySchool
        key={i}
        GSRating={school.gs_rating}
        averageRating={school.average_rating}
        schoolName={school.name}
        schoolType={school.type}
        gradeRange={school.level}
        city={school.city}
        state={school.state}
        distance={school.distance}
        schoolUrl={school.links.show}
        nearbySchoolsType={this.props.nearbySchoolsType}
        />);
    }.bind(this));
  }

  pageLeft() {
    this.setState({
      offset: this.state.offset - this.pageSize
    });
    this.trackPagination('Previous');
  }

  pageRight() {
    if(this.onPenultimateOrLastPage()) {
      this.requestSchools();
    }
    this.setState({
      offset: this.state.offset + this.pageSize
    });
    this.trackPagination('Next');
  }

  // true if on 2nd-to-last OR last page
  onPenultimateOrLastPage() {
    return this.state.offset >= (this.props.schools.length - (2 * this.pageSize));
  }

  shouldGetMoreSchools() {
    return (
      this.props.schools !== undefined && 
      (this.state.offset + this.pageSize >= this.props.schools.length - this.pageSize)
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
    let onClick = '';
    if(this.canPageLeft()) {
      className = 'active';
      onClick = this.pageLeft;
    }
    return (<div className={"prev " + className} onClick={onClick}>
      <span className="icon-chevron-left"></span>
    </div>);
  }

  pageRightButton() {
    let className = '';
    let onClick = '';
    if(this.canPageRight()) {
      className = 'active';
      onClick = this.pageRight;
    }
    return (
      <div className={"next " + className} onClick={onClick}>
        <span className="icon-chevron-right"></span>
      </div>);
  }

  renderSpinny() {
    let content = <div style={{height: '80px', width:'100%',display:'block'}}></div>
    return (<div><SpinnyWheel content={content}/></div>);
  }

  waitingForInitialSchools() {
    return this.props.schools === undefined;
  }

  noSchoolsFound() {
    return this.props.allSchoolsLoaded && this.props.schools.length === 0;
  }

  render() {
    if(this.waitingForInitialSchools()) {
      return this.renderSpinny();
    } else if (this.noSchoolsFound()) {
      return <div style={{'text-align':'center'}}>No schools found</div>
    }
    return (
      <div className="slider">
        {this.pageLeftButton()}
        <div className="slider-body">{this.renderNearbySchools()}</div>
        {this.pageRightButton()}
      </div>
    )
  }
}

export default NearbySchoolsList;
