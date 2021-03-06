import React from "react";
import PropTypes from "prop-types";
import { t } from "util/i18n";
import { findDistrictCalendarWithNCES as fetchDistrictCalendar } from "../../api_clients/calendar";
import InfoBox from "../school_profiles/info_box";
import LoadingOverlay from "../search/loading_overlay";
import Drawer from "../drawer";

class Calendar extends React.Component {
  static propTypes = {
    locality: PropTypes.obj,
    pageType: PropTypes.string.isRequired
  };

  static defaultProps = {
    locality: {},
    pageType: ""
  };

  constructor(props) {
    super(props);
    this.state = {
      isLoading: true,
      didFail: false,
      data: [],
      error: ""
    };

    this.renderCalendarEvent = this.renderCalendarEvent.bind(this);
  };

  parseEventsPayload(json) {
    let validEvents = [];
    let currentDate = this.formatDateObject(new Date());

    if (json[0] === 'vcalendar' && json.length > 2) {
      let jsonEvents = json.filter(element => element[0] === 'vevent');

      for (let i = 0; i < jsonEvents.length; i++) {
        if (Array.isArray(jsonEvents[i][1])) {
          let event = jsonEvents[i][1];
          let name = this.getValueFromEventArray(event, 'summary');
          let startDate = this.parseDateString(this.getValueFromEventArray(event, 'dtstart'));

          if (name && startDate && this.eventIsFutureDate(currentDate, startDate)) {
            let startDateFormatted = this.formatShortDateString(startDate);
            let eventData = { startDate: startDateFormatted, name: name };
            validEvents.push(eventData);
          }
        }
      }
    }
    return validEvents;
  };

  // Removes time from date object so we can compare MM/DD/YY 
  formatDateObject(date) {
    return [date.getFullYear(), date.getMonth() + 1, date.getDate()];
  }

  parseDateString(date) {
    return date.split("-").map(value => parseInt(value));
  }

  eventIsFutureDate(today, eventDateArray) {
    let [todayYear, todayMonth, todayDate] = today; 
    let [eventYear, eventMonth, eventDate] = eventDateArray;
    
    if (eventYear > todayYear) {
      return true;
    } else if ((eventYear === todayYear) && (eventMonth > todayMonth)) {
      return true;
    } else if ((eventYear === todayYear) && (eventMonth === todayMonth) && (eventDate >= todayDate)) {
      return true;
    } else {
      return false;
    }
  }

  formatShortDateString(dateArray) {
    let [eventYear, eventMonth, eventDate] = dateArray;
    
    return `${eventMonth}/${eventDate}/${eventYear}`;
  }

  getValueFromEventArray(event, valueName) {
    for (let i=0; i < event.length; i++) {
      if (event[i][0] === valueName && event[i].length > 3) {
        return event[i][3];
      } 
    }
    return null;
  }

  componentDidMount() {
    fetchDistrictCalendar(this.props.locality.calendarURL, this.props.locality.nces_code)
      .done($jsonRes => this.setState({
        isLoading: false,
        data: this.parseEventsPayload($jsonRes)
      }))
      .fail(error => this.setState({
        isLoading: false,
        didFail: true,
        error: error 
      }))
  }

  renderCalendarHeader() {
    return (
      <div className="row bar-graph-display">
        <div className="test-score-container clearfix calendar-header">
          <div className="col-sm-2">{ t('date') }</div>
          <div className="col-sm-1"></div>
          <div className="col-sm-9">{ t('event') }</div>
        </div>
      </div>
    )
  }

  renderCalendarEvent(event) {
    return (
      <div className="row bar-graph-display">
        <div className="test-score-container clearfix">
          <div className="col-sm-2 calendar-event-date">{ event.startDate }</div>
          <div className="col-sm-1"></div>
          <div className="col-sm-9 calendar-event-name">{ event.name }</div>
        </div>
      </div>
    )
  }

  render() {
    let calendarEvents = this.state.data;
    let calendarEventsInitial = calendarEvents.slice(0,5).map(event => this.renderCalendarEvent(event));
    let calendarEventsForDrawer = calendarEvents.slice(5).map(event => this.renderCalendarEvent(event));

    if (this.state.isLoading === true) {
      return (
        <section className="calendar-module">
          <div className="null-state">
            <h3>Loading...</h3>
            <LoadingOverlay numItems={6} />
          </div>
        </section>
      )
    } else if (this.state.didFail === true || this.state.data.length === 0) {
      return (
        <section className="calendar-module">
          <div className="null-state">
            <h4>{ t('district_calendar_no_results') }</h4>
          </div>
        </section>
      )
    } else {
      const sources = t('district_calendar_sources_html');
        return (
          <React.Fragment>
            <section className="calendar-module">
              <div className="calendar-content">
                { this.renderCalendarHeader() }
                { calendarEventsInitial }
                { calendarEventsForDrawer.length > 0 && 
                  <div className="rating-container__more-items">
                    <Drawer
                      content={ calendarEventsForDrawer }
                      trackingCategory={ `${this.props.pageType}` }
                      trackingAction={ "Show More" }
                      trackingLabel={ "Calendar" }
                    />
                  </div>
                }
              </div>
            </section>
            <InfoBox content={sources} element_type="sources" >{ t('See notes') }</InfoBox>
          </React.Fragment>
        )
    }
  }
}

export default Calendar;