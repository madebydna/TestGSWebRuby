import { addQueryParamToUrl } from '../util/uri';
import { t } from '../util/i18n';

function getHomesAndRentalsServiceUrl() {
  if(gon) {
    return gon.homes_and_rentals_service_url;
  } else {
    return null;
  }
}

// requires gon
export function fetchHomesAndRentals(forSaleOrForRent, city, state, zip, numberOfListings = 3) {
  let serviceUrl = getHomesAndRentalsServiceUrl();

  if(forSaleOrForRent != 'forSale' && forSaleOrForRent != 'forRent') {
    throw 'Invalid argument forSaleOrForRent, must be forRent or forSale';
  }
  if(!zip || !(city && state)) {
    throw 'Zip, or a combination city and state, are required.';
  }

  let region = zip ? zip : city + ', ' + state;

  let options = {
    output: 'json',
    noOfListings: numberOfListings,
    status: forSaleOrForRent,
    region: region
  }

  return $.ajax({
    url: serviceUrl,
    data: options,
    type: 'GET',
    dataType: 'jsonp'
  });
};

export function decorateListing(listing) {
  let bedrooms = function() {
    let beds = parseFloat(listing.bedrooms);
    if(isNaN(beds) || beds == 0) {
      return t('Studio');
    } else {
      return parseFloat(listing.bedrooms) + ' ' + t('beds');
    }
  };

  let bathrooms = function() {
    if(listing.bathrooms) {
      // parseFloat trims 1.0 down to 1
      return parseFloat(listing.bathrooms) + ' ' + t('baths');
    }
  };

  let size = function() {
    if(listing.finishedSqFt && listing.finishedSqFt != '0') {
      return listing.finishedSqFt + ' ' + t('sqft');
    }
  };

  return {
    fullAddress: function() {
      if(listing && listing.address) {
        return listing.address.street + ", " + listing.address.city + ", " + listing.address.state + " " + listing.address.zipcode
      }
    },

    price: function() {
      if(listing.price) {
        return '$' + listing.price.replace(/(\d)(?=(\d{3})+(\.|$))/g, '$1,');
      }
    },

    largerImageUrl: function() {
      // I was told that our service provider told us to do string
      // substitution on the image url to get different sizes of images
      if(document.documentElement.clientWidth < 768) {
        return listing.largeImageLink.replace('/p_b/', '/p_b/');
      } else {
        return listing.largeImageLink.replace('/p_b/', '/p_c/');
      }
    },

    pipeSeparatedDetails: function() {
      let details = [
        bedrooms(),
        bathrooms(),
        size()
      ];
      details = details.filter(detail => !!detail);
      return details.join(' | ');
    },

    //cbpartner=Great+Schools
    //utm_source=Great_Schools
    //utm_medium=referral
    //utm_campaign=nearbyhomes_profiles
    detailPageLink: function(utm_campaign='nearbyhomes_profiles') {
      return addCampaignCode(listing.detailPageLink, utm_campaign);
    }
  }
};

export function addCampaignCode(url, utm_campaign='nearbyhomes_profiles') {
  url = addQueryParamToUrl('cbpartner', 'Great+Schools', url);
  url = addQueryParamToUrl('utm_source', 'Great_Schools', url);
  url = addQueryParamToUrl('utm_medium', 'referral', url);
  url = addQueryParamToUrl('utm_campaign', utm_campaign, url);
  return url;
};

export function nearbyHomesUrl(city, state, utm_campaign='nearbyhomes_profiles') {
  return addCampaignCode(
    'https://www.zillow.com/' +
    city.toLowerCase().replace(' ', '-') + '-' + state.toLowerCase(),
      utm_campaign
  );
};

export function borrowingPageUrl() {
  return 'https://www.zillow.com/home-loans/?utm_source=greatschools&utm_medium=referral&utm_campaign=LFPurchase#/purchase&source=LFPurchaseGS&mp=RD-DYNJYJG'
};
