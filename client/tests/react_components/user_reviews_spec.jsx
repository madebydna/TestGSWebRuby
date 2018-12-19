import React from 'react';
import { shallow, mount } from 'enzyme';
import { expect } from 'chai';
import { describe, describe as context, it } from 'mocha';

import UserReviews from 'react_components/review/user_reviews';
import RecentReviews from 'react_components/community/recent_reviews';
import ReviewsList from 'react_components/review/reviews_list';

describe('<UserReviews />', ()=> {
  const recentReview = {
    avatar: 1,
    five_star_review: {
      answer: '3',
      answer_label: null, 
      answer_value: '3',
      comment: 'Excellent. My kids love going to school every day.',
      date_published: 'September 05, 2018',
      id: 3604492,
      links: {
        flag: '/gsr/reviews/3604492/flag'
      },
      school_id: 36,
      topic_label: 'Overall experience'
    },
    id: 1403387618630687500,
    most_recent_date: 'September 05, 2018',
    school_name: 'Oxford Elementary School',
    school_url: '/california/berkeley/36-Oxford-Elementary-School',
    school_user_digest: '2FeGy5A8zdNTk1aGx3yV7A==',
    topical_reviews: [],
    user_type_label: 'Parent'
  };

  it('contains a UserReviews component', () => {
    const wrapper = shallow(
      <UserReviews {...recentReview} />
    );
    expect(wrapper.containsMatchingElement(<UserReviews />));
  });

  context('Displays five star reviews', () => {
    it('displays the correct number of filled-in stars corresponding to the rating', () => {
      const wrapper = shallow(
        <UserReviews {...recentReview} />
      );
      expect(wrapper.find('.answer .five-stars .icon-star.filled-star').length).to.equal(3);
    });

    it('displays five stars total (filled and empty)', () => {
      const wrapper = shallow(
        <UserReviews {...recentReview} />
      );
      const filledStars = wrapper.find('.answer .five-stars .icon-star.filled-star');
      const emptyStars = wrapper.find('.answer .five-stars .icon-star.empty-star');

      expect(filledStars.length + emptyStars.length).to.equal(5);
    });
  });
});