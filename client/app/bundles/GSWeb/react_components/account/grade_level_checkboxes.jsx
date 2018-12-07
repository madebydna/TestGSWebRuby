import React from 'react';
import PropTypes from 'prop-types';
import {
  getStudentGrades,
  deleteStudentGrade,
  addStudentGrade
} from 'api_clients/subscriptions';
import { filter, debounce } from 'lodash';
import GradeLevelSelectable from './grade_level_selectable';

const ordinalize = i => {
  const j = i % 10;
  const k = i % 100;
  if (j === 1 && k !== 11) {
    return `${i}st`;
  }
  if (j === 2 && k !== 12) {
    return `${i}nd`;
  }
  if (j === 3 && k !== 13) {
    return `${i}rd`;
  }
  return `${i}th`;
};

const GradeLevelCheckboxes = ({ grades }) => (
  <GradeLevelSelectable grades={grades}>
    {({ grade, active, toggle }) => (
      <span className="grade-level" onClick={toggle} key={grade}>
        <input type="checkbox" checked={active} onChange={() => null} />
        <label>
          {grade !== 'KG' && grade !== 'PK' && ordinalize(parseInt(grade, 10))}
          {(grade === 'KG' || grade === 'PK') && grade}
        </label>
      </span>
    )}
  </GradeLevelSelectable>
);

export default GradeLevelCheckboxes;
