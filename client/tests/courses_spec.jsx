import React from 'react';
import { shallow } from 'enzyme';
import sinon from 'sinon';
import { expect } from 'chai';

import Courses from '../app/bundles/GSWeb/react_components/courses.jsx';
import Drawer from '../app/bundles/GSWeb/react_components/drawer.jsx';
import CourseSubject from '../app/bundles/GSWeb/react_components/course_subject.jsx';
import NoDataModuleCta from '../app/bundles/GSWeb/react_components/no_data_module_cta.jsx';

describe('<Courses />', function() {

  let courseEnrollmentsAndRatings = {
    "English": {
      "courses": [
        "AP English Language",
        "AP English Literature"
      ],
      "rating": 9
    }
  };

  it('should show the available subjects', function() {
    const wrapper = shallow(<Courses course_enrollments_and_ratings={courseEnrollmentsAndRatings}/>);
    expect(wrapper.containsMatchingElement(<CourseSubject />)).to.equal(true);
  });

  it('should show no data cta if there are no subjects', function() {
    const wrapper = shallow(<Courses course_enrollments_and_ratings={''}/>);
    expect(wrapper.containsMatchingElement(<NoDataModuleCta />)).to.equal(true);
  });

  it('when four subjects, should render drawer with one', function() {
    let courseEnrollmentsAndRatings = {
      "One": {
        "courses": [ "Foo" ]
      },
      "Two": {
        "courses": [ "Foo" ]
      },
      "Three": {
        "courses": [ "Foo" ]
      },
      "Four": {
        "courses": [ "Foo" ]
      }
    };

    const wrapper = shallow(<Courses course_enrollments_and_ratings={courseEnrollmentsAndRatings}/>);
    expect(wrapper.containsMatchingElement(<Drawer/>)).to.equal(true);
    // should also check to see what items were given to the drawer
    // but wasn't able to figure that out
  });

});
