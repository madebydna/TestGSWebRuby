//= require jquery
//= require modals/modal

var requestModalViaAjaxDeferredObject;
var modalShowDeferredObject;
var ModalConstructor = function() {};

describe('GS.modal.manager', function() {
  describe('.showModal', function() {
    beforeEach(function() {
      requestModalViaAjaxDeferredObject = $.Deferred();
      modalShowDeferredObject = $.Deferred();
      ModalConstructor.prototype = {
        show: function() { return modalShowDeferredObject; },
        initialize: function() {},
        $getModal: function() { return []; },
        getUrlWithParams: function() {}
      };
      sinon.stub(jQuery, 'ajax', function () {
        return requestModalViaAjaxDeferredObject;
      });
    });
    afterEach(function() {
      jQuery.ajax.restore();
    });

    it('it should return resolved when ajax call and modal.show resolves', function() {
      requestModalViaAjaxDeferredObject.resolve();
      modalShowDeferredObject.resolve();
      expect(GS.modal.manager.showModal(ModalConstructor)
        .state()).to.eq("resolved");
    });
    it('it should return rejected when modal.show is rejected', function() {
      requestModalViaAjaxDeferredObject.resolve();
      modalShowDeferredObject.reject();
      expect(GS.modal.manager.showModal(ModalConstructor)
        .state()).to.eq("rejected");
    });
    it('it should return rejected when requestModalViaAjax is rejected', function() {
      requestModalViaAjaxDeferredObject.reject();
      modalShowDeferredObject.resolve();
      expect(GS.modal.manager.showModal(ModalConstructor)
        .state()).to.eq("rejected");
    });
  });
});

