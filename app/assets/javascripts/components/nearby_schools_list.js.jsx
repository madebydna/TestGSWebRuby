class NearbySchoolsList extends React.Component {

  constructor(props) {
    super(props);
    this.state = {
      offset: 0,
      pageSize: 3
    }
    this.pageLeft = this.pageLeft.bind(this);
    this.pageRight = this.pageRight.bind(this);
  }

  schools() {
    return this.props.schools.slice(this.state.offset, this.state.offset + this.state.pageSize);
  }

  getSchools(count) {
    if(this.props.allSchoolsLoaded) {
      return;
    }
    this.props.getSchools(
      this.props.school.state,
      this.props.school.id,
      (this.props.schools || []).length,
      (count || this.state.pageSize)
    );
  }

  getInitialSchools() {
    this.getSchools(6);
  }

  componentDidMount(nextProps) {
    if(this.props.schools === undefined) {
      this.getInitialSchools();
    }
  }

  // componentWillReceiveProps(nextProps) {
  //   if(nextProps.visible === true && this.props.schools === undefined) {
  //     this.getInitialSchools();
  //   }
  // }

  renderNearbySchools() {
    return this.schools().map(function(school,i) {
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
        />);
    });
  }

  pageLeft() {
    this.setState({
      offset: this.state.offset - this.state.pageSize
    });
  }

  pageRight() {
    if(this.onPenultimateOrLastPage()) {
      this.getSchools();
    }
    this.setState({
      offset: this.state.offset + this.state.pageSize
    });
  }

  // true if on 2nd-to-last OR last page
  onPenultimateOrLastPage() {
    return this.state.offset >= (this.props.schools.length - (2 * this.state.pageSize));
  }

  shouldGetMoreSchools() {
    return (
      this.props.schools !== undefined && 
      (this.state.offset + this.state.pageSize >= this.props.schools.length - this.state.pageSize)
    );
  }

  canPageLeft() {
    return this.state.offset >= this.state.pageSize;
  }

  canPageRight() {
    return this.state.offset + this.state.pageSize < this.props.schools.length;
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

  render() {
    if(this.props.schools === undefined || this.props.school.length == 0) {
      return this.renderSpinny();
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

NearbySchoolsList.propTypes = {
  visible: React.PropTypes.bool.isRequired,
  schools: React.PropTypes.array,
  allSchoolsLoaded: React.PropTypes.bool
};
