if(gon.pagename == "Overview"){

    GS.track.set_common_omniture_data();

    $(function () {
        if($("#galleria").get(0)){
            Galleria.run('#galleria');
        }
    });
}