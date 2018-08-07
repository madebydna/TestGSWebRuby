import React from 'react';
import ollie from 'school_profiles/owl_tutorial_prompt.png';
import { t } from 'util/i18n';
import ModalTooltip from './modal_tooltip';

const content = (
  <div className='rating-help-container'>
    <h4>{t('search_help.help')}</h4>
    <p>{t('search_help.greatschool_rating')}
    </p>
    <div className='ratings-scale-container'>
      <div className='rating-scale'>
        <div className='search-help-circle circle-rating--1'>1</div>
        <div className='search-help-circle circle-rating--2'>2</div>
        <div className='search-help-circle circle-rating--3'>3</div>
        <div className='search-help-circle circle-rating--4'>4</div>
      </div>
      <div className='rating-scale'>
        <div className='search-help-circle circle-rating--5'>5</div>
        <div className='search-help-circle circle-rating--6'>6</div>
      </div>
      <div className='rating-scale'>
        <div className='search-help-circle circle-rating--7'>7</div>
        <div className='search-help-circle circle-rating--8'>8</div>
        <div className='search-help-circle circle-rating--9'>9</div>
        <div className='search-help-circle circle-rating--10'>10</div>
      </div>
    </div>
    <div className='ratings-scale-container'>
      <div className='word-scale rating-scale'>{t('search_help.rating.below_average')}</div>
      <div className='word-scale rating-scale'>{t('search_help.rating.average')}</div>
      <div className='word-scale rating-scale'>{t('search_help.rating.above_average')}</div>
    </div>
    <hr />
    <p className='search-help-unrated'><span className='circle circle-rating--gray'/>
      {t('search_help.currently_rated')} <br/> <br/>
      {t('search_help.currently_rated_info')}
    </p>
    <hr />
    <p><strong>{t('search_help.search_suggestions')}</strong>
      <br />
    </p>
    <a href='https://greatschools.zendesk.com/hc/en-us/requests/new'>{t('search_help.send_feedback')}</a>
  </div>
);

const SearchHelpMenu = () => (
    <ModalTooltip content={content}>
      <img src={ollie} className='owly_size' alt='' />
    </ModalTooltip>
)

export default SearchHelpMenu;
