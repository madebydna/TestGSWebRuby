describe('uri_params', function() {

    function unstub(obj) {
        if(obj.hasOwnProperty('restore')) {
            obj.restore();
        }
    }

    beforeEach(function() {
        console.log('before test');
    });

    afterEach(function() {
        unstub(GS.uri.Uri.getPath);
        unstub(GS.uri.Uri.getFromQueryString);
    });

    describe('state abbreviation from URL', function() {
        it('should be undefined when no state in URL', function() {
            expect(GS.stateAbbreviationFromUrl()).to.eq(undefined);
        });

        it('should get the state from the path', function() {
            sinon.stub(GS.uri.Uri, 'getPath').returns('/california/alameda/1-school');
            expect(GS.stateAbbreviationFromUrl()).to.eq('ca');
        });

        it('handles multi-word state names', function() {
            sinon.stub(GS.uri.Uri, 'getPath').returns('/district-of-columbia/alameda/1-school');
            expect(GS.stateAbbreviationFromUrl()).to.eq('dc');
        });

        it('should get the state from the query string', function() {
            sinon.stub(GS.uri.Uri, 'getFromQueryString').returns('CA');
            expect(GS.stateAbbreviationFromUrl()).to.eq('ca');
        });

        it('state in query string takes precedence over state in path', function() {
            sinon.stub(GS.uri.Uri, 'getFromQueryString').returns('DC');
            sinon.stub(GS.uri.Uri, 'getPath').returns('/california/alameda/1-school');
            expect(GS.stateAbbreviationFromUrl()).to.eq('dc');
        });

        it('handles malformed state param', function() {
            sinon.stub(GS.uri.Uri, 'getFromQueryString').returns('0');
            expect(GS.stateAbbreviationFromUrl()).to.eq(undefined);
        });

        it('falls back on path if malformed state in query string', function() {
            sinon.stub(GS.uri.Uri, 'getFromQueryString').returns('0');
            sinon.stub(GS.uri.Uri, 'getPath').returns('/california/alameda/1-school');
            expect(GS.stateAbbreviationFromUrl()).to.eq('ca');
        });
    });
});