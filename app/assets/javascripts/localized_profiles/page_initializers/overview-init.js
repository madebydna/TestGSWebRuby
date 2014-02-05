if(gon.pagename == "Overview"){

    GS.track.setOmnitureData();

    $(function () {
        if($("#galleria").get(0)){
            Galleria.run('#galleria');
        }
    });
}