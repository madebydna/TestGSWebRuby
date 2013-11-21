var GS = GS || {};
GS.window = GS.window || {};
GS.window.sizing = GS.window.sizing || {};

GS.window.sizing.width = function(){
    return $(window).width();
}

GS.window.sizing.overviewPieChartWidth = function(){
    var obj = GS.window.sizing.sizeBasedObjHash();
    return obj.overview.pieChartWidth;
}

GS.window.sizing.overviewPieChartHeight = function(){
    var obj = GS.window.sizing.sizeBasedObjHash();
    return obj.overview.pieChartHeight;
}

GS.window.sizing.overviewPieChartLegend = function(){
    var obj = GS.window.sizing.sizeBasedObjHash();
    return obj.overview.pieChartLegend;
}

GS.window.sizing.globalMapWidth = function(){
    var obj = GS.window.sizing.sizeBasedObjHash();
    return obj.global.googleMapWidth;
}

GS.window.sizing.globalContactMap = function(id){
    var obj =  GS.window.sizing.sizeBasedObjHash();
    $("."+id).attr("src", obj.global.map);
}

GS.window.sizing.sizeBasedObjHash = function() {
    var sizeHash ={}
    sizeHash.overview = {}
    sizeHash.details = {}
    sizeHash.quality = {}
    sizeHash.global = {}
    //default
    sizeHash.overview.pieChartLegend = "{position: 'right',alignment: 'center'}";
    var windowWidth = GS.window.sizing.width();
    if(windowWidth >= 990){
        sizeHash.overview.pieChartWidth = 960;
        sizeHash.overview.pieChartHeight = 300;
        sizeHash.global.map = gon.contact_map.lg;
    }
    else{
        if(windowWidth < 990 && windowWidth >= 768 ){
            sizeHash.overview.pieChartWidth = 700;
            sizeHash.overview.pieChartHeight = 300;
            sizeHash.global.map = gon.contact_map.lg;
        }
        else{
            if(windowWidth  < 768 && windowWidth  > 480 ){
                sizeHash.overview.pieChartWidth = 460;
                sizeHash.overview.pieChartHeight = 200;
                sizeHash.global.map = gon.contact_map.md;
            }
            else{
                if(windowWidth  <= 480){
                    sizeHash.overview.pieChartWidth = 280;
                    sizeHash.overview.pieChartHeight = 280;
                    sizeHash.overview.pieChartLegend = 'none';
                    sizeHash.global.map = gon.contact_map.sm;
                }
            }
        }
    }
    return sizeHash;
};