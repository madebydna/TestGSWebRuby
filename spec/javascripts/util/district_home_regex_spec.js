//= require util/uri

describe('District home regex', function() {
  describe('District home regex', function() {

    var districtHomeRegexp = /^\/[^\/]+\/[^\/]+\/(?!preschools)(?!(\d+-)).+$/;

    it('does not match Lowell High School', function () {
      expect(districtHomeRegexp.test('/california/san-francisco/6397-Lowell-High-School/')).to.eq(false);
    });

    it('does not match 1-2-3 Grow Child Care', function() {
      expect(districtHomeRegexp.test('/nebraska/lincoln/preschools/1-2-3-Grow-Child-Care/2732/')).to.eq(false);
    });


    it('matches Alameda School District', function () {
      expect(districtHomeRegexp.test('/california/san-francisco/Alameda-School-District/')).to.eq(true);
    });

    it('matches st. paul public school district', function () {
      expect(districtHomeRegexp.test('/california/san-francisco/st.-paul-public-school-district/')).to.eq(true);
    });

    it('matches district 12', function () {
      expect(districtHomeRegexp.test('/california/san-francisco/district-12/')).to.eq(true);
    });

    it('matches 12th district', function () {
      expect(districtHomeRegexp.test('/california/san-francisco/12th-district/')).to.eq(true);
    });

    it('matches district #12', function () {
      expect(districtHomeRegexp.test('/california/san-francisco/district-%2312/')).to.eq(true);
    });
  });

});