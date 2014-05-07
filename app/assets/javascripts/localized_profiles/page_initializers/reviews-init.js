if(gon.pagename == "Reviews"){

    GS.track.setOmnitureData();

    $(function () {
        GS.reviews.initializeReviewHandlers();
    });
    GS.ad.addToAdSlotDefinitionArray(GS.reviewsAd.reviewContent, this, []);
    GS.ad.addToAdShowArray(GS.reviewsAd.writeDivAndFillReviews, this, [0]);
}