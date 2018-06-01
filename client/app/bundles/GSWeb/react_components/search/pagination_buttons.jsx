import React from 'react';
import PropTypes from 'prop-types';
import Selectable from 'react_components/selectable';
import pageNumbers from 'util/pagination';
import AnchorButton from 'react_components/anchor_button';

const PaginationButtons = ({ page, totalPages, onPageChanged }) => {
  const { prev, next, range } = pageNumbers(page, totalPages);
  const options = [];

  options.push({
    key: '<',
    value: prev,
    label: '<',
    preventSelect: !prev
  });
  range.forEach(pageNum => {
    options.push({
      key: pageNum,
      value: pageNum,
      label: pageNum
    });
  });
  options.push({
    key: '>',
    value: next,
    label: '>',
    preventSelect: !next
  });

  return (
    <Selectable
      options={options}
      allowDeselect={false}
      activeOptions={options.filter(o => o.value === page)}
      onSelect={({ value } = {}) => {
        if (value && value !== page) {
          onPageChanged(value);
        }
      }}
    >
      {opts =>
        opts.map(({ option, active, select }) => (
          <AnchorButton
            key={option.key}
            enabled={!option.preventSelect}
            active={active}
            onClick={select}
          >
            {option.label}
          </AnchorButton>
        ))
      }
    </Selectable>
  );
};

PaginationButtons.propTypes = {
  page: PropTypes.number.isRequired,
  totalPages: PropTypes.number.isRequired,
  onPageChanged: PropTypes.func.isRequired
};

PaginationButtons.defaultProps = {};

export default PaginationButtons;
