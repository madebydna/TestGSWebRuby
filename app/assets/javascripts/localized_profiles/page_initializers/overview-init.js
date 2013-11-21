if(gon.pagename == "Overview"){
    $(function () {
        if($("#galleria").get(0)){
            Galleria.run('#galleria');
        }
        GS.window.sizing.globalContactMap("js-contact_map_image");
    });
}