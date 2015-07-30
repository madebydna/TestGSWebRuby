//= require util/uri
//= require util/i18n

describe('GS.I18n', function() {
  function unstub(obj) {
    if(obj.hasOwnProperty('restore')) {
      obj.restore();
    }
  }

  before(function() {
    GS.I18n._setTranslationsHash({
      'en': {
        'foo': 'bar'
      },
      'es': {
        'foo': 'baz'
      }
    });
  });

  afterEach(function() {
    unstub(GS.I18n.currentLocale);
    unstub(GS.uri.Uri.getHref);
  });

  describe('.t', function() {
    it('translates foo', function() {
      sinon.stub(GS.I18n, 'currentLocale').returns('en');
      var key = 'foo';
      expect(GS.I18n.t(key)).to.eq('bar');
    });

    it('translates foo in spanish', function() {
      sinon.stub(GS.uri.Uri, 'getHref').returns('www.greatschools.org?lang=es');
      var key = 'foo';
      expect(GS.I18n.t(key)).to.eq('baz');
    });
  });
});
