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
import Module from './module';

export default class StudentsWithDisabilities extends Module {
  static defaultProps = {
    title: 'Students with Disabilities',
    info_text: GS.I18n.t('Student with disabilities tooltip'),
    icon_classes: GS.I18n.t('Student with disabilities icon')
  }
};

