//= require util/tracking

describe('tracking', function() {

  describe('doUnlessTrackingIsDisabled', function() {

    var onlyIfOmnitureExistsFunctions = ['setSProps','setEVars','setEvents','setLists','trackEvent'];
    _.each(onlyIfOmnitureExistsFunctions, function(func) {
      it(func + ' should call the doUnlessTrackingIsDisabled', function() {
        s = undefined;
        var spy = sinon.spy(GS.track, "doUnlessTrackingIsDisabled");
        GS.track[func]([]);
        expect(GS.track.doUnlessTrackingIsDisabled.called).to.eq(true);
        GS.track.doUnlessTrackingIsDisabled.restore();
      });
    });
  });

});
