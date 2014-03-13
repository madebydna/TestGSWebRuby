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
});
