//= require util/uri

describe('GS.uri.Uri', function() {
  function unstub(obj) {
    if(obj.hasOwnProperty('restore')) {
      obj.restore();
    }
  }

  afterEach(function() {
    unstub(GS.uri.Uri.getHref);
  });

  describe('.getQueryStringFromObject', function() {
    it('returns an empty string for empty inputs', function() {
        expect(GS.uri.Uri.getQueryStringFromObject({})).to.eq('');
    });

    it('sets query parameters based on keys and values', function() {
      obj = { key: 'value' };
      expect(GS.uri.Uri.getQueryStringFromObject(obj)).to.eq('?key=value');
    });

    it('encodes arrays within an object', function() {
      obj = { foo: ['bar', 'baz'] };
      expect(GS.uri.Uri.getQueryStringFromObject(obj)).to.eq('?foo=bar&foo=baz');
    });

    it('encodes objects recursively', function() {
      obj = { foo: 'bar', baz: { timmy: [1, 2, 3] } };
      expect(GS.uri.Uri.getQueryStringFromObject(obj)).to.eq('?foo=bar&?timmy=1&timmy=2&timmy=3');
    });

    it('sanitizes undefined values', function() {
      obj = { foo: undefined, bar: 'baz' };
      expect(GS.uri.Uri.getQueryStringFromObject(obj)).to.eq('?foo=&bar=baz');
    });
  });

  describe('.getQueryStringFromGivenUrl', function() {
    it('returns foo=bar for www.greatschools.org?foo=bar', function() {
      url = 'www.greatschools.org?foo=123';
      expect(GS.uri.Uri.getQueryStringFromGivenUrl(url)).to.eq('foo=123');
    });

    it('gets query string from URLs with anchors', function() {
      url = 'www.greatschools.org?foo=123#anchor';
      expect(GS.uri.Uri.getQueryStringFromGivenUrl(url)).to.eq('foo=123');
    });
  });

  describe('.stripQueryStringFromUrl', function() {
    it('returns full URL when URL has no query string', function() {
      url = 'http://www.greatschools.org';
      expect(GS.uri.Uri.stripQueryStringFromUrl(url)).to.eq(url);
    });

    it('returns undefined when URL is undefined', function() {
      url = undefined;
      expect(GS.uri.Uri.stripQueryStringFromUrl(url)).to.eq(url);
    });

    it('returns empty string when url is empty string', function() {
      url = '';
      expect(GS.uri.Uri.stripQueryStringFromUrl(url)).to.eq(url);
    });

    it('returns www.greatschools.org for www.greatschools.org?foo=bar', function() {
      url = 'www.greatschools.org?foo=bar';
      expect(GS.uri.Uri.stripQueryStringFromUrl(url)).to.eq('www.greatschools.org');
    });

    it('returns www.greatschools.org for www.greatschools.org?foo=bar&bar=baz', function() {
      url = 'www.greatschools.org?foo=bar&bar=baz';
      expect(GS.uri.Uri.stripQueryStringFromUrl(url)).to.eq('www.greatschools.org');
    });

    it('strips off query string when URL contains an anchor', function() {
      url = 'www.greatschools.org?foo=bar#anchor';
      expect(GS.uri.Uri.stripQueryStringFromUrl(url)).to.eq('www.greatschools.org#anchor');
      url = 'www.greatschools.org?#anchor';
      expect(GS.uri.Uri.stripQueryStringFromUrl(url)).to.eq('www.greatschools.org#anchor');
    });
  });

  describe('.stripQueryStringAndAnchorFromUrl', function() {
    it('returns full URL when URL has no query string or anchor', function() {
      url = 'http://www.greatschools.org';
      expect(GS.uri.Uri.stripQueryStringAndAnchorFromUrl(url)).to.eq(url);
    });

    it('returns undefined when URL is undefined', function() {
      url = undefined;
      expect(GS.uri.Uri.stripQueryStringAndAnchorFromUrl(url)).to.eq(url);
    });

    it('returns empty string when url is empty string', function() {
      url = '';
      expect(GS.uri.Uri.stripQueryStringAndAnchorFromUrl(url)).to.eq(url);
    });

    it('returns www.greatschools.org for www.greatschools.org?foo=bar', function() {
      url = 'www.greatschools.org?foo=bar';
      expect(GS.uri.Uri.stripQueryStringAndAnchorFromUrl(url)).to.eq('www.greatschools.org');
    });

    it('returns www.greatschools.org for www.greatschools.org?foo=bar&bar=baz', function() {
      url = 'www.greatschools.org?foo=bar&bar=baz';
      expect(GS.uri.Uri.stripQueryStringAndAnchorFromUrl(url)).to.eq('www.greatschools.org');
    });

    it('strips off query string and anchor when URL contains a query string and anchor', function() {
      url = 'www.greatschools.org?foo=bar#anchor';
      expect(GS.uri.Uri.stripQueryStringAndAnchorFromUrl(url)).to.eq('www.greatschools.org');
    });

    it('strips off anchor when URL contains an anchor', function() {
      url = 'www.greatschools.org?#anchor';
      expect(GS.uri.Uri.stripQueryStringAndAnchorFromUrl(url)).to.eq('www.greatschools.org');
    });
  });

  describe('.addQueryParamToUrl', function() {
    it('overwrites a param which already exists', function() {
      var param = 'foo';
      var value = 'bar';
      var url = 'www.greatschools.org?foo=123';
      expect(GS.uri.Uri.addQueryParamToUrl(param, value, url)).to.eq('www.greatschools.org?foo=bar');
    });

    it('correctly adds a new param', function() {
      var param = 'foo';
      var value = 'bar';
      var url = 'www.greatschools.org?bar=baz';
      expect(GS.uri.Uri.addQueryParamToUrl(param, value, url)).to.eq('www.greatschools.org?bar=baz&foo=bar');
    });

    it('handles URLs with anchors', function() {
      var param = 'foo';
      var value = 'bar';
      var url = 'www.greatschools.org#anchor';
      expect(GS.uri.Uri.addQueryParamToUrl(param, value, url)).to.eq('www.greatschools.org?foo=bar#anchor');
    });
  });

  describe('.copyParam', function() {
    it('copies a param from source URL to target URL', function() {
      var param = 'foo';
      var sourceUrl = 'www.greatschools.org?foo=bar';
      var targetUrl = 'www.greatschools.org';
      expect(GS.uri.Uri.copyParam(param, sourceUrl, targetUrl)).to.eq('www.greatschools.org?foo=bar');
    });

    it('overwrites param on target URL', function() {
      var param = 'foo';
      var sourceUrl = 'www.greatschools.org?foo=bar';
      var targetUrl = 'www.greatschools.org?foo=123&bar=baz';
      expect(GS.uri.Uri.copyParam(param, sourceUrl, targetUrl)).to.eq('www.greatschools.org?foo=bar&bar=baz');
    });

    it('handles URLs that have params that are empty strings', function() {
      var param = 'bar';
      var sourceUrl = 'www.greatschools.org?tricky=&bar=baz';
      var targetUrl = 'www.greatschools.org?foo=bar&teehee=';
      expect(GS.uri.Uri.copyParam(param, sourceUrl, targetUrl)).to.eq('www.greatschools.org?foo=bar&teehee=&bar=baz');
    });

    it('handles URLs that have anchors', function() {
      var param = 'foo';
      var sourceUrl = 'www.greatschools.org?foo=bar';
      var targetUrl = 'www.greatschools.org#anchor';
      expect(GS.uri.Uri.copyParam(param, sourceUrl, targetUrl)).to.eq('www.greatschools.org?foo=bar#anchor');
    });
  });

  describe('.getAnchorFromUrl', function() {
    it('gets anchor from url without query string', function() {
      var url = 'www.greatschools.org#anchor';
      expect(GS.uri.Uri.getAnchorFromUrl(url)).to.eq('#anchor');
    });

    it('gets anchor from url with query string', function() {
      var url = 'www.greatschools.org?foo=bar&bar=baz#anchor';
      expect(GS.uri.Uri.getAnchorFromUrl(url)).to.eq('#anchor');
    });
  });

  describe('.getQueryStringFromURL', function() {
    it('gets correct query string when it has an anchor', function() {
      var url = 'www.greatschools.org?foo=bar&bar=baz#anchor';
      sinon.stub(GS.uri.Uri, 'getHref').returns(url);
      expect(GS.uri.Uri.getQueryStringFromURL()).to.eq('foo=bar&bar=baz');
    });
  });

  describe('.getValueOfQueryParam', function() {
    it('gets param value from url with anchor', function() {
      var url = 'www.greatschools.org?foo=bar#anchor';
      sinon.stub(GS.uri.Uri, 'getHref').returns(url);
      expect(GS.uri.Uri.getValueOfQueryParam('foo')).to.eq('bar');
    });

    it('handles case where param does not exist', function() {
      var url = 'www.greatschools.org?foo=bar#anchor';
      sinon.stub(GS.uri.Uri, 'getHref').returns(url);
      expect(GS.uri.Uri.getValueOfQueryParam('baz')).to.eq(undefined);
    });
  });
});
