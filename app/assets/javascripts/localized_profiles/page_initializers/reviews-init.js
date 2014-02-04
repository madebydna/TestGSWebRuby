if(gon.pagename == "Reviews"){

    GS.track.set_common_omniture_data();

    $(function () {
        GS.reviews.initializeReviewHandlers();
    });
}