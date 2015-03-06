//= require util/dependency_init
//= require util/states

describe('states', function() {

    describe('state abbreviation', function() {

        it('should handle bad values', function() {
            expect(GS.states.abbreviation(undefined)).to.eq(undefined);
            expect(GS.states.abbreviation(null)).to.eq(undefined);
            expect(GS.states.abbreviation(0)).to.eq(undefined);
            expect(GS.states.abbreviation('garbage')).to.eq(undefined);
        });

        it('should handle dc', function() {
            expect(GS.states.abbreviation('washington dc')).to.eq('dc');
            expect(GS.states.abbreviation('district of columbia')).to.eq('dc');
        });

    });

    describe('state name', function() {

        it('should handle bad values', function() {
            expect(GS.states.name(undefined)).to.eq(undefined);
            expect(GS.states.name(null)).to.eq(undefined);
            expect(GS.states.name(0)).to.eq(undefined);
            expect(GS.states.name('garbage')).to.eq(undefined);
        });

        it('should handle dc', function() {
            expect(GS.states.name('dc')).to.eq('washington dc');
        });

    });
});
