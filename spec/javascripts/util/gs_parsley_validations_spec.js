//= require util/dependency_init
//= require resources/parsley
//= require util/gs_parsley_validations


describe('gs parsley validation', function () {

    describe('currency', function () {

        it('should allow well-formed currency', function () {
            expect(GS.gsParsleyValidations.currency('$1000')).to.eq(true);
            expect(GS.gsParsleyValidations.currency('$1,000')).to.eq(true);
            expect(GS.gsParsleyValidations.currency('$1000.00')).to.eq(true);
        });

        it('should require dollar sign', function () {
            expect(GS.gsParsleyValidations.currency('1000')).to.eq(false);
            expect(GS.gsParsleyValidations.currency('1000.00')).to.eq(false);
            expect(GS.gsParsleyValidations.currency('1,000.00')).to.eq(false);
        });

        it('should allow two decimal places if there any', function () {
            expect(GS.gsParsleyValidations.currency('$1,000.00')).to.eq(true);
        });

        it('should reject non-currency characters', function () {
            expect(GS.gsParsleyValidations.currency('$10,00a.00')).to.eq(false);
        });

        it('should require correct comma usage', function () {
            expect(GS.gsParsleyValidations.currency('$10,00.00')).to.eq(false);
            expect(GS.gsParsleyValidations.currency(',100.00')).to.eq(false);
        });

        it('should not allow incorrect decimals placement', function () {
            expect(GS.gsParsleyValidations.currency('1.000.00')).to.eq(false);
            expect(GS.gsParsleyValidations.currency('$1,000.0')).to.eq(false);
            expect(GS.gsParsleyValidations.currency('$1,000.0')).to.eq(false);
        });
    });
});


