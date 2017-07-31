import React, { PropTypes } from 'react';
import BarGraphBase from './graphs/bar_graph_base';
import TestScores from './graphs/test_scores';
import PersonBar from '../visualizations/person_bar';
import BasicDataModuleRow from '../school_profiles/basic_data_module_row';
import PlainNumber from './graphs/plain_number';
import Rating from './graphs/rating';
import EquitySection from './equity_section';
import NoDataModuleCta from '../no_data_module_cta';


export default class SchoolProfileComponent extends React.Component {
  static propTypes = {
    title: React.PropTypes.string,
    anchor: React.PropTypes.string,
    subtitle:  React.PropTypes.string,
    info_text: React.PropTypes.string,
    icon_classes: React.PropTypes.string,
    sources: React.PropTypes.string,
    rating: React.PropTypes.number,
    data: React.PropTypes.array,
    analytics_id: React.PropTypes.string,
    faq: PropTypes.shape({
      cta: PropTypes.string.isRequired,
      content: PropTypes.string.isRequired
    }),
    qualaroo_module_link: React.PropTypes.string
  };

  static defaultProps = {
    data: []
  }

  constructor(props) {
    super(props);
  }

  subjectConfig(name, type, values, narration) {
    if (values) {
      // This is for titles in the test scores
      if(!(values instanceof Array)){
        return {
          subject: name,
          component: <TestScores test_scores={values}/>,
          explanation: <div dangerouslySetInnerHTML={{__html: narration}} />
        };
      }

      if (values.length > 0) {
        let displayType = type || 'bar';
        let component = null;
        if (displayType == 'plain') {
          component = <PlainNumber values={values}/>
        } else if (displayType == 'person') {
          component = <div>
            {values.map((value, index) => 
              <BasicDataModuleRow {...value} key={index}>
                <PersonBar {...value} />
              </BasicDataModuleRow>)
            }
          </div>
        } else if (displayType == 'person_reversed') {
          component = <div>
            {values.map((value, index) => 
              <BasicDataModuleRow {...value} key={index}>
                <PersonBar {...value} invertedRatings={true} />
              </BasicDataModuleRow>)
            }
          </div>
        } else if (displayType == 'rating') {
          component = <div>
            {values.map((value, index) =>
                <BasicDataModuleRow {...value} key={index}>
                  <Rating {...value} />
                </BasicDataModuleRow>)
            }
          </div>
        } else {
          component = <div>
            {values.map((value, index) => 
              <BasicDataModuleRow {...value} key={index}>
                <BarGraphBase {...value} />
              </BasicDataModuleRow>)
            }
          </div>
        }
        return {
          subject: name,
          component: component,
          explanation: <div dangerouslySetInnerHTML={{__html: narration}} />
        };
      }
    }
    return null;
  }

  equitySectionProps() {
    let sectionConfig = {
      title: this.props.title,
      anchor: this.props.anchor,
      subtitle: <span dangerouslySetInnerHTML={{__html: this.props.subtitle}} />,
      rating: this.props.rating,
      info_text: this.props.info_text,
      icon_classes: this.props.icon_classes
    };

    let sectionContent = this.props.data.map(subjectProps => {
      let data = subjectProps.data || {};
      let content = Object.keys(data).map((subject) => {
        let { type, values, narration } = data[subject];
        return this.subjectConfig(subject, type, values, narration);
      })
      if (content.length > 0) {
        return { ...subjectProps, content: content };
      }
    }).filter(o => o != null);

    if(sectionContent.length > 0) {
      sectionConfig['section_content'] = sectionContent;
    } else {
      sectionConfig['message'] = <NoDataModuleCta moduleName={this.props.title} />
    }

    return sectionConfig;
  }

  render() {
    let equitySectionProps = this.equitySectionProps();
    let equitySection;

    equitySection = <EquitySection
      sources={this.props.sources}
      faq={this.props.faq}
      qualaroo_module_link={this.props.qualaroo_module_link}
      {...equitySectionProps}
    />

    let analyticsId = this.props.analytics_id;
    if (!equitySectionProps || !equitySectionProps['section_content']) {
      // no data
      analyticsId += '-empty';
    }

    return (
      <div id={analyticsId}>{ equitySection }</div>
    );
  }
};

