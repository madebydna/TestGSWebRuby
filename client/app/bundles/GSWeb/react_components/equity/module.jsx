import React, { PropTypes } from 'react';
import testScoresHelpers from '../../util/test_scores_helpers';
import EquityBarGraph from './graphs/equity_bar_graph';
import BarGraphBase from './graphs/bar_graph_base';
import PersonBar from './graphs/person_bar';
import PlainNumber from './graphs/plain_number';
import BarGraphWithEnrollmentInLabel from './graphs/bar_graph_with_enrollment_in_label';
import EquitySection from './equity_section';
import InfoCircle from '../info_circle';
import NoDataModuleCta from '../no_data_module_cta';

export default class Module extends React.Component {
  static propTypes = {
    sources: React.PropTypes.string,
    data: React.PropTypes.object,
    rating: React.PropTypes.number
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
      if (values.length > 0) {
        let displayType = data['type'] || 'bar';
        let component = null;
        if (displayType == 'plain') {
          component = <PlainNumber values={values}/>
        } else if (displayType == 'person') {
          component = <PersonBar values={values} />
        } else if (displayType == 'person_reversed') {
          component = <PersonBar values={values} invertedRatings={true} />
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
    let section1Content = [];
    let config = [];

    if (this.props.data) {
      section1Content = Object.keys(this.props.data).map(
        category => this.sectionConfig(category, this.props.data[category])
      ).filter(o => o != null);
    }

    let sectionConfig = {
      section_info:{
        title: this.props.title,
        subtitle: this.props.subtitle,
        rating: this.props.rating,
        info_text: this.props.info_text,
        icon_classes: this.props.icon_classes
      }
    };

    if(section1Content.length > 0) {
      sectionConfig['section_content'] = section1Content;
    } else {
      sectionConfig['section_info']['message'] = <NoDataModuleCta moduleName={this.props.title} />
    }

    config.push(sectionConfig);

    return config;
  }

  render() {
    let equityConfig = this.equityConfiguration();

    var equitySections = [];
    for (var i = 0; i < equityConfig.length; i++) {
      equitySections.push(<EquitySection
          key={i}
          equity_config={ equityConfig[i]}
          sources={this.props.sources}
      />)
    }
    return (
        <div>
          { equitySections }
        </div>
    );
  }
};

