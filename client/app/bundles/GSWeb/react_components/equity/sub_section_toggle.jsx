import React, { PropTypes } from 'react';
import SectionSubNavigation from './tabs/section_sub_navigation';
import EquityContentPane from './equity_content_pane';
import { handleThirdAnchor } from '../../components/anchor_router';

export default class SubSectionToggle extends React.Component {

  static propTypes = {
    defaultTab: React.PropTypes.string,
    parent_tab: React.PropTypes.string,
    equity_config: React.PropTypes.arrayOf(React.PropTypes.shape({
      subject: React.PropTypes.string,
      component: React.PropTypes.object,
      explanation: React.PropTypes.element
    }))
  };

  constructor(props) {
    super(props);
    let defaultTabIndex = 0;
    if(props.defaultTab) {
      defaultTabIndex = this.tabNames().indexOf(props.defaultTab);
    }
    this.state = {
      active: defaultTabIndex
    };
  }

  tabNames() {
    return this.props.equity_config.map(c => c.subject);
  }

  componentDidMount() {
    let mapping = {
      'Test scores': 'Test_scores',
      'Graduation rates': 'Graduation_rates',
      'Advanced coursework': 'Advanced_coursework',
      'Discipline & attendance': 'Discipline_and_attendance',
      'Resultados de exámenes': 'Test_scores',
      'Índices de Graduación': 'Graduation_rates',
      'Cursos avanzados': 'Advanced_coursework',
      'Disciplina y asistencia': 'Discipline_and_attendance'
    };
    handleThirdAnchor(
      mapping[this.props.parent_tab], tokens => {
        let section_content = this.props.equity_config;
        let index = section_content.findIndex((config) => {
          return this.buttonAnchorName(config.subject) == tokens[0];
        });
        if(index == -1) {
          index = 0;
        }
        this.setState({ active: index });
      }
    );
  }

  buttonAnchorName(value) {
    return value.replace(/\s/g, "_");
  }

  renderContent() {
    let item = this.props.equity_config[this.state.active];
    return <div className={'tabs-panel tabs-panel_selected'}>
      <EquityContentPane key={this.state.active} graph={item["component"]} text={item["explanation"]} />
    </div>
  }

  render() {
    return <div>
      <div className="sub-section-navigation">
        <SectionSubNavigation
          items={this.tabNames()}
          active={this.state.active}
          onTabClick={this.handleTabClick.bind(this)}
          parent_tab={this.props.parent_tab}
        />
      </div>
      {this.renderContent()}
    </div>
  }

  handleTabClick(index) {
    this.setState({active: index})
  }
}
