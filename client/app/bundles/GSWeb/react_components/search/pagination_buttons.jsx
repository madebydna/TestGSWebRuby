import React from 'react';
import PropTypes from 'prop-types';
import Selectable from 'react_components/selectable';
import pageNumbers from 'util/pagination';
import AnchorButton from 'react_components/anchor_button';
import { t } from 'util/i18n';

const PaginationButtons = ({ page, totalPages, onPageChanged, mobileView }) => {
  const { prev, next, range } = pageNumbers(page, totalPages);
  const options = [];

  if (mobileView) {
    options.push({
      key: '<',
      value: prev,
      label: (
        <span>
          <span className="icon-caret-down rotate-text-90" /> {t('Previous')} 25
        </span>
      ),
      preventSelect: !prev
    });
    options.push({
      key: '>',
      value: next,
      label: (
        <span>
          {t('Next')} 25 <span className="icon-caret-down rotate-text-270" />
        </span>
      ),
      preventSelect: !next
    });
  } else {
    options.push({
      key: '<',
      value: prev,
      label: <span className="icon-chevron-right rotate-text-180" />,
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
      label: <span className="icon-chevron-right" />,
      preventSelect: !next
    });
  }

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
