import React from 'react';
import { shallow, mount } from 'enzyme';
import sinon from 'sinon';
import { expect } from 'chai';
import { before, describe, describe as context, it } from 'mocha';

import RecentReviews from 'react_components/community/recent_reviews';
import ReviewsList from 'react_components/review/reviews_list';

describe('<RecentReviews/>', ()=> {
  const wrapper = mount(<RecentReviews />);

  it('contains a ReviewsList component', () => {
    expect(wrapper.containsMatchingElement(<ReviewsList />));
  })

  context('contains a button for end users to add a review', () => {
    const addAReview = wrapper.find('.add-review-container');
    it('contains a add-review-container class name',() => {
      expect(addAReview).to.have.lengthOf(1);
    });
    it('contains a button to add a review', () => {
      expect(addAReview.children().containsMatchingElement(<button>Add a review</button>));
    });
    it('has the correct href when clicked',() => {
      expect(addAReview.find('a').at(0).props().href).to.equal('/reviews/');
    });
  })

  context('RecentReviews component handles props correctly', () => {
    it('Handles community prop correctly', () => {
      const recentReview = shallow(<RecentReviews community="city" />)
      expect(recentReview.find('p').text()).to.equal("recent_reviews.city_blurb")
      recentReview.setProps({community: 'district'})
      expect(recentReview.setProps({ community: 'district' }).find('p').text()).to.equal("recent_reviews.district_blurb")
      recentReview.setProps({ community: 'random' })
      expect(recentReview.setProps({ community: 'district' }).find('p').text()).to.equal("recent_reviews.district_blurb")
    });
  });
});