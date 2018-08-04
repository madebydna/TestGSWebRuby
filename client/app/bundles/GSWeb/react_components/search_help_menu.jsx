import React from 'react';
import ollie from 'school_profiles/owl_tutorial_prompt.png';
import ModalTooltip from './modal_tooltip';

const content = (
  <div className='rating-help-container'>
    <h4>(PLACEHOLDER)Help</h4>
    <hr />
    <p>(PLACEHOLDER)GreatSchools’ Summary Rating provides an overall snapshot of school
       quality. Ratings follow a 1-10 scale:
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
      <div className='word-scale rating-scale'>Below <br /> average</div>
      <div className='word-scale rating-scale'>Average</div>
      <div className='word-scale rating-scale'>Above <br /> average</div>
    </div>
    <hr />
    <p>(PLACEHOLDER)Currently unrated schools:

      For some schools, we do not have enough data from state or national education
      agencies to provide a rating.
    </p>
    <hr />
    <p>(PLACEHOLDER)Help us improve the new search <br/>
       <a href='#'>Send feedback</a>
    </p>
  </div>
);

const SearchHelpMenu = () => {

  return(
    <ModalTooltip content={content}>
      <img src={ollie} className='owly_size' alt='' />
    </ModalTooltip>
  )
}

export default SearchHelpMenu;
