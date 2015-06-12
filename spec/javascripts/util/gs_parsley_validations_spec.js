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

    describe('youtubeVimeoTag', function(){
        it('should not allow videos without correct host', function(){
            expect(GS.gsParsleyValidations.youtubeVimeoTag('https://www.youtubee.com/watch?v=FxdvM7epMUA')).to.eq(false);
            expect(GS.gsParsleyValidations.youtubeVimeoTag('https://www.youtube.comm/watch?v=FxdvM7epMUA')).to.eq(false);
            expect(GS.gsParsleyValidations.youtubeVimeoTag('https://www.youtub.com/watch?v=FxdvM7epMUA')).to.eq(false);
            expect(GS.gsParsleyValidations.youtubeVimeoTag('https://www.youtube.co/watch?v=FxdvM7epMUA')).to.eq(false);
            expect(GS.gsParsleyValidations.youtubeVimeoTag('https://yout.be/FxdvM7epMUA')).to.eq(false);
            expect(GS.gsParsleyValidations.youtubeVimeoTag('https://youtu.b/FxdvM7epMUA')).to.eq(false);
            expect(GS.gsParsleyValidations.youtubeVimeoTag('https://youtuu.be/FxdvM7epMUA')).to.eq(false);
            expect(GS.gsParsleyValidations.youtubeVimeoTag('https://youtu.bee/FxdvM7epMUA')).to.eq(false);
            expect(GS.gsParsleyValidations.youtubeVimeoTag('https://vime.com/channels/staffpicks/129096640')).to.eq(false);
            expect(GS.gsParsleyValidations.youtubeVimeoTag('https://vimeo.co/129096640')).to.eq(false);
            expect(GS.gsParsleyValidations.youtubeVimeoTag('https://vimeoo.com/129096640')).to.eq(false);
            expect(GS.gsParsleyValidations.youtubeVimeoTag('https://vimeo.comm/129096640')).to.eq(false);
        });

        it('should allow youtube url without parameters', function(){
            expect(GS.gsParsleyValidations.youtubeVimeoTag('https://www.youtube.com/watch?v=FxdvM7epMUA')).to.eq(true);
            expect(GS.gsParsleyValidations.youtubeVimeoTag('https://youtu.be/FxdvM7epMUA')).to.eq(true);
        });

        it('should allow youtube url with parameters', function(){
            expect(GS.gsParsleyValidations.youtubeVimeoTag('https://www.youtube.com/watch?v=FxdvM7epMUA&maru=kawaii?hana=kawaii')).to.eq(true);
            expect(GS.gsParsleyValidations.youtubeVimeoTag('https://youtu.be/FxdvM7epMUA&maru=kawaii?hana=kawaii')).to.eq(true);
        });

        it('should allow vimeo urls without parameters', function(){
            expect(GS.gsParsleyValidations.youtubeVimeoTag('https://vimeo.com/channels/staffpicks/129096640')).to.eq(true);
            expect(GS.gsParsleyValidations.youtubeVimeoTag('https://vimeo.com/129096640')).to.eq(true);
        });

        it('should allow vimeo urls with parameters', function(){
            expect(GS.gsParsleyValidations.youtubeVimeoTag('https://vimeo.com/channels/staffpicks/129096640&maru=kawaii?hana=kawaii')).to.eq(true);
            expect(GS.gsParsleyValidations.youtubeVimeoTag('https://vimeo.com/129096640&maru=kawaii?hana=kawaii')).to.eq(true);

        });
    });
});


