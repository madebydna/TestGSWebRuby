import React from 'react';
import PropTypes from 'prop-types';
import Selectable from 'react_components/selectable';
import pageNumbers from 'util/pagination';
import AnchorButton from 'react_components/anchor_button';
import { t } from 'util/i18n';
import { putIntoQueryString } from 'util/uri';

const link = (page) => {
  const queryString = putIntoQueryString(window.location.search, 'page', page, true)
  return `${window.location.pathname}${queryString}`
};

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
      preventSelect: !prev,
      link: link(prev)
    });
    options.push({
      key: '>',
      value: next,
      label: (
        <span>
          {t('Next')} 25 <span className="icon-caret-down rotate-text-270" />
        </span>
      ),
      preventSelect: !next,
      link: link(next)
    });
  } else {
    options.push({
      key: '<',
      value: prev,
      label: <span className="icon-chevron-right rotate-text-180" />,
      preventSelect: !prev,
      link: link(prev)
    });
    range.forEach(pageNum => {
      options.push({
        key: pageNum,
        value: pageNum,
        label: pageNum,
        link: link(pageNum)
      });
    });
    options.push({
      key: '>',
      value: next,
      label: <span className="icon-chevron-right" />,
      preventSelect: !next,
      link: link(next)
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
            href={!option.preventSelect && option.link}
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
