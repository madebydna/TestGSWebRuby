if(gon.pagename == "Reviews"){

    $(function () {
        GS.schoolProfiles.initializeSaveThisSchoolButton();
        GS.reviews.initializeReviewHandlers();
    });
    GS.ad.addToAdSlotDefinitionArray(GS.reviewsAd.reviewContent, this, []);
    GS.ad.addToAdShowArray(GS.reviewsAd.writeDivAndFillReviews, this, [0]);
    GS.schoolProfiles.showSignUpForSchoolModalAfterDelay();

}