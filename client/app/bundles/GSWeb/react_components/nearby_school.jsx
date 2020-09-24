import React from 'react';
import PropTypes from 'prop-types';
import { t } from "util/i18n";
import { addCampaignCode } from 'api_clients/homes_and_rentals';

export default class NearbySchool extends React.Component {

  static propTypes = {
    GSRating: PropTypes.number,
    averageRating: PropTypes.number,
    schoolName: PropTypes.string,
    schoolType: PropTypes.string,
    gradeRange: PropTypes.string,
    city: PropTypes.string,
    state: PropTypes.string,
    distance: PropTypes.number,
    schoolUrl: PropTypes.string,
    nearbySchoolsType: PropTypes.string,
    schoolZipcode: PropTypes.string
  }

  constructor(props) {
    super(props);
  }

  renderGSRating() {
    if(!this.props.GSRating) {
      return null;
    }
    return (
      <div className={"circle-rating circle-rating--small circle-rating--" + this.props.GSRating}>
        {this.props.GSRating}<span className="rating-circle-small">/10</span>
      </div>
    );
  }

  fiveStars(numberFilled) {
    if (numberFilled === undefined || numberFilled == null) {
      return null;
    }
    if(!this.props.GSRating) {
      return null;
    }

    var filled = [];
    for (var i=0; i < numberFilled; i++) {
      filled.push(<span className="icon-star filled-star" key={i}></span>);
    }
    var empty = [];
    for (i=numberFilled; i < 5; i++) {
      empty.push(<span className="icon-star empty-star" key={i}></span>);
    }
    return(
      <span className="five-stars">
        { filled }
        { empty }
      </span>
    )
  }

  renderRating() {
    if(this.props.GSRating !== undefined && this.props.GSRating != 'nr') {
      return (
        <div className="rating">
          {this.renderGSRating()}
          {this.fiveStars(this.props.averageRating)}
        </div>
      );
    } else {
      return (<div className="no-rating"></div>);
    }
  }

  distance() {
    if(this.props.distance === undefined) {
      return null;
    }
    return (Math.round(this.props.distance * 100) / 100) + " miles";
  }

  render() {
    return (
      <div className="nearby-school">
        {this.renderRating()}
        <div>
          <a
            className="js-gaClick"
            href={this.props.schoolUrl}
            data-ga-click-category="Profile"
            data-ga-click-action={this.props.nearbySchoolsType}
            data-ga-click-label={this.props.schoolUrl}
          >
            {this.props.schoolName}
          </a>
          <div className="school-info">
            <span>{this.props.schoolType}</span>
            <span>{this.props.gradeRange}</span>
            <span>
              {this.props.city}, {this.props.state}
            </span>
          </div>
          <div>{this.distance()}</div>
          <div style={{ marginTop: "5px" }}>
            <a
              className="icon icon-house active"
              href={`https://www.zillow.com/${this.props.state}-${this.props.schoolZipcode}?`}
              href={addCampaignCode(
                `https://www.zillow.com/${this.props.state}-${this.props.schoolZipcode}`,
                "schoolprofiles_schoollistings"
              )}
            >
              <span>&#32;{t('homes_for_sale')}</span>
            </a>
          </div>
        </div>
      </div>
    );
  }
}
