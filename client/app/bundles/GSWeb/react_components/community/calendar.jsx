import React from "react";
import PropTypes from "prop-types";
import { t } from "util/i18n";
import { findDistrictCalendarWithNCES as fetchDistrictCalendar } from "../../api_clients/calendar";
// import analyticsEvent or anything else?
import LoadingOverlay from "../search/loading_overlay";
import Drawer from '../drawer';

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
// TODO: Error handling!

  dataFromJson(json) {
    let events = [];
    if (json[0] === 'vcalendar' && json.length > 2) {
      for (let i=2; i < json.length; i++) {
        if (json[i][0] === 'vevent' && Array.isArray(json[i][1])) {
          let event = json[i][1];
          let startDate = this.formatShortDateString(this.getValueFromEventArray(event, 'dtstart'));
          let name = this.getValueFromEventArray(event, 'summary');
          if (startDate && name) {
            let eventData = { startDate: startDate, name: name };
            events.push(eventData);
          }
        } 
      }
    }
    return events;
  };

  formatShortDateString(date) {
    return new Date(date + ' PST').toLocaleDateString("en-US");
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
        data: this.dataFromJson($jsonRes)
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
            <h4>{t('district_calendar_no_results')}</h4>
          </div>
        </section>
      )
    } else {
        return (
          <section className="calendar-module">
            <div className="calendar-content">
              { this.renderCalendarHeader() }
              { calendarEventsInitial }
              { calendarEventsForDrawer.length > 0 && 
                <div className="rating-container__more-items">
                  <Drawer
                    content={ calendarEventsForDrawer }
                  />
                </div>
              }
            </div>
          </section>
        )
    }
  }
}

export default Calendar;