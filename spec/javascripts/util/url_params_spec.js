//= require util/uri
//= require util/states
//= require util/url_params

describe('url_params', function() {

    function unstub(obj) {
        if(obj.hasOwnProperty('restore')) {
            obj.restore();
        }
    }

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

    describe('school id from URL', function() {
        it('should be undefined when no school id in URL', function() {
            expect(GS.schoolIdFromUrl()).to.eq(undefined);
        });

        it('should get the school id from the path', function() {
            sinon.stub(GS.uri.Uri, 'getPath').returns('/california/alameda/1-school');
            expect(GS.schoolIdFromUrl()).to.eq(1);
        });

        it('should get the school id from the path for preK', function() {
            sinon.stub(GS.uri.Uri, 'getPath').returns('/michigan/detroit/preschools/YMCA-Child-Care-Center-Upa/6907/reviews/');
            expect(GS.schoolIdFromUrl()).to.eq(6907);
        });
        it('should get the school id from the path for preK when preschool name has digit in it', function() {
            sinon.stub(GS.uri.Uri, 'getPath').returns('/michigan/detroit/preschools/Gr8t-YMCA-Child-Care-Center-Upa/6907/reviews/');
            expect(GS.schoolIdFromUrl()).to.eq(6907);
        });
    });
    describe('school name from URL', function() {
        it('should be undefined when no school name in URL', function() {
            expect(GS.schoolNameFromUrl()).to.eq(undefined);
        });

        it('should get the school name from the path', function() {
            sinon.stub(GS.uri.Uri, 'getPath').returns('/california/alameda/1-alameda-high-school');
            expect(GS.schoolNameFromUrl()).to.eq('alameda high school');
        });

        it('should get the school name from the path for preK', function() {
            sinon.stub(GS.uri.Uri, 'getPath').returns('/michigan/detroit/preschools/YMCA-Child-Care-Center-Upa/6907/reviews/');
            console.log(GS.schoolNameFromUrl());
            expect(GS.schoolNameFromUrl()).to.eq('YMCA Child Care Center Upa');
        });

    });

});
