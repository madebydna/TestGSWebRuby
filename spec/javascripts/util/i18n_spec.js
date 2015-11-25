//= require util/uri
//= require util/util
//= require util/i18n

describe('GS.I18n', function() {
  function unstub(obj) {
    if(obj.hasOwnProperty('restore')) {
      obj.restore();
    }
  }

  before(function() {
    GS.I18n._setTranslationsHash({
      'foo': 'bar'
    });
  });

  afterEach(function() {
    unstub(GS.uri.Uri.getHref);
    unstub(GS.uri.Uri.getValueOfQueryParam);
  });

  describe('.t', function() {
    it('translates foo', function() {
      var key = 'foo';
      expect(GS.I18n.t(key)).to.eq('bar');
    });

    it('supports a default value', function() {
      var key = '%$&#!';
      var defaultValue = 'bar';
      expect(
        GS.I18n.t(
          key,
          {
            'default': defaultValue
          }
        )
      ).to.eq(defaultValue);
    });
  });

  describe('.currentLocale', function() {
    it('returns current en locale when no locale is set', function() {
      sinon.stub(GS.uri.Uri, 'getValueOfQueryParam').returns(null);
      expect(GS.I18n.currentLocale()).to.eq('en');
    });

    it('returns current locale when locale is set', function() {
      sinon.stub(GS.uri.Uri, 'getValueOfQueryParam').returns('es');
      expect(GS.I18n.currentLocale()).to.eq('es');
    });
  });

});
