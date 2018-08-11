import React from 'react';
import ollie from 'school_profiles/owl_tutorial_prompt.png';
import { t } from 'util/i18n';
import OpenableCloseable from './openable_closeable';
import Links from '../components/links'

const content = (close) => (
  <div className='rating-help-container'>
    <span
      className="icon-close btn-close"
      onClick={close}
      onKeyPress={close}
      role="button"
      aria-label={t('Close filters')}
    />
    <h4>{t('search_help.help')}</h4>
    <p>{t('search_help.greatschool_rating')}
    </p>
    <div className='ratings-scale-container'>
      <div className='block-container'>
        <div className='rating-scale'>
          <div className='help-circle circle-rating--1'>1</div>
          <div className='help-circle circle-rating--2'>2</div>
          <div className='help-circle circle-rating--3'>3</div>
          <div className='help-circle circle-rating--4'>4</div>
        </div>
        <p className='word-scale'>{t('search_help.rating.below_average')}</p>
      </div>
      <div className='block-container'>
        <div className='rating-scale'>
          <div className='help-circle circle-rating--5'>5</div>
          <div className='help-circle circle-rating--6'>6</div>
        </div>
        <p className='word-scale'>{t('search_help.rating.average')}</p>
      </div>
      <div className='block-container'>
        <div className='rating-scale'>
          <div className='help-circle circle-rating--7'>7</div>
          <div className='help-circle circle-rating--8'>8</div>
          <div className='help-circle circle-rating--9'>9</div>
          <div className='help-circle circle-rating--10'>10</div>
        </div>
        <p className='word-scale'>{t('search_help.rating.above_average')}</p>
      </div>
    </div>
    <hr />
    <p>
      <div className='circle-ur circle-rating--gray unrated'/>
      {t('search_help.currently_rated')} <br/> <br/>
      {t('search_help.currently_rated_info')}
    </p>
    <hr />
    <p><strong>{t('search_help.search_suggestions')}</strong>
      <br />
    </p>
    <a href={Links.zendesk} target='_blank'>{t('search_help.send_feedback')}</a>
  </div>
);

const HelpTooltip = () => (
  <OpenableCloseable>
    {(isOpen, { open, close, toggle }) => (
        <React.Fragment>
          <img
            src={ollie}
            className="owly_size"
            alt="owl_icon"
            onClick={toggle}
          />
          <div className= {isOpen ? "help-overlay" : ""}>
            {isOpen ? content(close) : null}
          </div>
        </React.Fragment>
    )}
  </OpenableCloseable>
);

export default HelpTooltip;
