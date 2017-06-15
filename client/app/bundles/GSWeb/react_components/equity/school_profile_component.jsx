import React, { PropTypes } from 'react';
import BarGraphBase from './graphs/bar_graph_base';
import TestScores from './graphs/test_scores';
import PersonBar from './graphs/person_bar';
import PlainNumber from './graphs/plain_number';
import EquitySection from './equity_section';
import NoDataModuleCta from '../no_data_module_cta';


export default class SchoolProfileComponent extends React.Component {
  static propTypes = {
    title: React.PropTypes.string,
    anchor: React.PropTypes.string,
    analytics_id: React.PropTypes.string,
    subtitle:  React.PropTypes.string,
    info_text: React.PropTypes.string,
    icon_classes: React.PropTypes.string,
    sources: React.PropTypes.string,
    data: React.PropTypes.object,
    rating: React.PropTypes.number,
    faq: PropTypes.shape({
      cta: PropTypes.string.isRequired,
      content: PropTypes.string.isRequired
    })
  };

  constructor(props) {
    super(props);
  }

  sectionConfig(name, data) {
    if (data) {
      let content = Object.keys(data).map((subject) => this.subjectConfig(subject, data[subject]))
      if (content.length > 0) {
        return {
          section_title: name,
          content: content
        };
      }
    }
    return null;
  }

  subjectConfig(name, data) {
    if (data && data['values']) {
      let values = data['values'];
      // This is for titles in the test scores
      if(!(values instanceof Array)){
        return {
          subject: name,
          component: <TestScores test_scores={values}/>,
          explanation: <div dangerouslySetInnerHTML={{__html: data['narration']}} />
        };
      }

      if (values.length > 0) {
        let displayType = data['type'] || 'bar';
        let component = null;
        if (displayType == 'plain') {
          component = <PlainNumber values={values}/>
        } else if (displayType == 'person') {
          component = <div>{values.map((value) => <PersonBar {...value} />) }</div>
        } else if (displayType == 'person_reversed') {
          component = <div>{values.map((value) => <PersonBar {...value} invertedRatings={true} />) }</div>
        } else {
          component = <BarGraphBase test_scores={values}/>
        }
        return {
          subject: name,
          component: component,
          explanation: <div dangerouslySetInnerHTML={{__html: data['narration']}} />
        };
      }
    }
    return null;
  }

  equityConfiguration(){
    let sectionContent = [];
    let config = [];

    if (this.props.data) {
      sectionContent = Object.keys(this.props.data).map(
        category => this.sectionConfig(category, this.props.data[category])
      ).filter(o => o != null);
    }

    let sectionConfig = {
      section_info:{
        title: this.props.title,
        anchor:this.props.anchor,
        subtitle: <span dangerouslySetInnerHTML={{__html: this.props.subtitle}} />,
        rating: this.props.rating,
        info_text: this.props.info_text,
        icon_classes: this.props.icon_classes
      }
    };

    if(sectionContent.length > 0) {
      sectionConfig['section_content'] = sectionContent;
    } else {
      sectionConfig['section_info']['message'] = <NoDataModuleCta moduleName={this.props.title} />
    }

    config.push(sectionConfig);

    return config;
  }

  render() {
    let equityConfig = this.equityConfiguration();

    var equitySections = [];
    var noData = true;
    for (var i = 0; i < equityConfig.length; i++) {
      equitySections.push(<EquitySection
          key={i}
          equity_config={ equityConfig[i]}
          sources={this.props.sources}
          faq={this.props.faq}
      />);
      if (equityConfig[i] && equityConfig[i]['section_content']) {
        noData = false;
      }
    }
    let analyticsId = this.props.analytics_id;
    if (noData) {
      analyticsId += '-empty';
    }
    return (
        <div id={analyticsId}>
          { equitySections }
        </div>
    );
  }
};

