import React from 'react';
import { shallow } from 'enzyme';
import { expect } from 'chai';
import { before, describe, describe as context, it } from 'mocha';

import CityLinks from 'react_components/community/city_links';

describe('<CityLinks />', () => {
  const cities = [
      {name: "Paris", url: "http://www.paris.gov"},
      {name: "London", url: "http://www.london.gov"},
      {name: "Tokyo", url: "http://www.tokyo.gov"},
      {name: "New York", url: "http://www.ny.gov"},
      {name: "San Francisco", url: "http://www.sf.gov"},
      {name: "Rio de Janeiro", url: "http://www.rio.gov"},
      {name: "Shanghai", url: "http://www.shanghai.gov"},
      {name: "Istanbul", url: "http://www.istanbul.gov"},
  ];

  let cityLinks = shallow(
      <CityLinks
        cities={cities}
        size={3}
      />
    );

  it('displays each city as an li tag', () => {
    expect(cityLinks.find('li')).to.have.lengthOf(8);
    expect(cityLinks.find('li').first().text()).to.equal('Paris');
  });

  it('links to each city', () => {
    expect(cityLinks.find('a')).to.have.lengthOf(8);
    expect(cityLinks.find('a').last().html()).to.equal('<a href="http://www.istanbul.gov">Istanbul</a>');
  });

    // const XS = 0;
    // const SM = 1;
    // const MD = 2;
    // const LG = 3;

  context('With 8 cities and a large screen size (two column)', () => {
    const all_items = cityLinks.find('li');
    it('has a line under the correct cities (1, 2, 3, 5, 6, 7)', () => {
        [0, 1, 2, 4, 5, 6].forEach((num) => {
            expect(all_items.at(num).exists('div.blue-line')).to.equal(true);
        });
    }) 
    it('has no line under the fourth city', () => {
        expect(all_items.at(3).exists('div.blue-line')).to.equal(false);
    }) 
    it('has no line under the eighth city', () => {
        expect(all_items.at(7).exists('div.blue-line')).to.equal(false);
    }) 
  });

  context('With 8 cities and a medium screen size (one column)', () => {
    let cityLinks = shallow(
        <CityLinks
          cities={cities}
          size={2}
        />
      );

    it('has a line under all cities except for the last', () => {
        [0, 1, 2, 3, 4, 5, 6].forEach((num) => {
            expect(cityLinks.find('li').at(num).exists('div.blue-line')).to.equal(true);
        });
        expect(cityLinks.find('li').at(7).exists('div.blue-line')).to.equal(false);
    });
  });

  context('With 4 cities and a large screen size (2 column)', () => {
    let cityLinks = shallow(
        <CityLinks
          cities={cities.slice(0, 4)}
          size={3}
        />
      );

    it('has no line under the fourth city', () => {
        expect(cityLinks.find('li').at(3).exists('div.blue-line')).to.equal(false);
    })
  });

  context('With 5 cities and a large screen size (2 column)', () => {
    let cityLinks = shallow(
        <CityLinks
          cities={cities.slice(0, 5)}
          size={3}
        />
      );

    it('has no line under the fourth city', () => {
        expect(cityLinks.find('li').at(3).exists('div.blue-line')).to.equal(false);
    });

    it('has no line under the fifth city', () => {
        expect(cityLinks.find('li').last().exists('div.blue-line')).to.equal(false);
    })
  });

  context('With 5 cities and a medium screen size (one column)', () => {
    let cityLinks = shallow(
        <CityLinks
          cities={cities.slice(0, 5)}
          size={2}
        />
      );

    it('has line under the fourth city', () => {
        expect(cityLinks.find('li').at(3).exists('div.blue-line')).to.equal(true);
    });

    it('has no line under the fifth city', () => {
        expect(cityLinks.find('li').last().exists('div.blue-line')).to.equal(false);
    })
  });
});
