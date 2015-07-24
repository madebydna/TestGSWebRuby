//= require util/uri

describe('GS.uri.Uri', function() {
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
      var param = 'bar'
      var sourceUrl = 'www.greatschools.org?tricky=&bar=baz';
      var targetUrl = 'www.greatschools.org?foo=bar&teehee=';
      expect(GS.uri.Uri.copyParam(param, sourceUrl, targetUrl)).to.eq('www.greatschools.org?foo=bar&teehee=&bar=baz');
    });
  });
});
