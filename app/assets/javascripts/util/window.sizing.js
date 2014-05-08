GS.window = GS.window || {};
GS.window.sizing = GS.window.sizing || {};

GS.window.sizing.width = function(){
    return $(window).width();
}

GS.window.sizing.pieChartWidth = function(chartname){
    var obj = GS.window.sizing.sizeBasedObjHash();
    return eval("obj."+chartname+".pieChartWidth");
}

GS.window.sizing.pieChartHeight = function(chartname){
    var obj = GS.window.sizing.sizeBasedObjHash();
    return eval("obj."+chartname+".pieChartHeight");
}

GS.window.sizing.pieChartLegend = function(chartname){
    var obj = GS.window.sizing.sizeBasedObjHash();
    return eval("obj."+chartname+".pieChartLegend");
}

GS.window.sizing.barChartWidth = function(chartname){
    var obj = GS.window.sizing.sizeBasedObjHash();
    return eval("obj."+chartname+".barChartWidth");
}

GS.window.sizing.barChartHeight = function(chartname){
    var obj = GS.window.sizing.sizeBasedObjHash();
    return eval("obj."+chartname+".barChartHeight");
}

GS.window.sizing.barChartLegend = function(chartname){
    var obj = GS.window.sizing.sizeBasedObjHash();
    return eval("obj."+chartname+".barChartLegend");
}
GS.window.sizing.barChartAreaWidth = function(chartname){
    var obj = GS.window.sizing.sizeBasedObjHash();
    return eval("obj."+chartname+".barChartAreaWidth");
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
    sizeHash.ethnicity = {}
    sizeHash.ethnicity.pieChartLegend = 'none';
    sizeHash.quality = {}
    sizeHash.testscores = {}
    sizeHash.global = {}
    //default
    sizeHash.overview.pieChartLegend = "{position: 'right',alignment: 'center'}";
    sizeHash.testscores.barChartLegend = 'right';
    sizeHash.testscores.barChartAreaWidth = '60%';

    var windowWidth = GS.window.sizing.width();
    if(windowWidth >= 990){
        sizeHash.overview.pieChartWidth = 960;
        sizeHash.overview.pieChartHeight = 300;
        sizeHash.ethnicity.pieChartWidth = 250;
        sizeHash.ethnicity.pieChartHeight = 250;
        sizeHash.testscores.barChartWidth = 700;
        sizeHash.testscores.barChartHeight = 300;
        if (gon.hasOwnProperty('contact_map') && gon.contact_map.hasOwnProperty('lg')) {
            sizeHash.global.map = gon.contact_map.lg;
        }

    }
    else{
        if(windowWidth < 990 && windowWidth >= 768 ){
            sizeHash.overview.pieChartWidth = 700;
            sizeHash.overview.pieChartHeight = 300;
            sizeHash.ethnicity.pieChartWidth = 280;
            sizeHash.ethnicity.pieChartHeight = 280;
            sizeHash.testscores.barChartWidth = 700;
            sizeHash.testscores.barChartHeight = 300;
            if (gon.hasOwnProperty('contact_map') && gon.contact_map.hasOwnProperty('lg')) {
                sizeHash.global.map = gon.contact_map.lg;
            }
        }
        else{
            if(windowWidth  < 768 && windowWidth  > 480 ){
                sizeHash.overview.pieChartWidth = 460;
                sizeHash.overview.pieChartHeight = 200;
                sizeHash.ethnicity.pieChartWidth = 280;
                sizeHash.ethnicity.pieChartHeight = 280;
                sizeHash.testscores.barChartWidth = 420;
                sizeHash.testscores.barChartHeight = 250;
                if (gon.hasOwnProperty('contact_map') && gon.contact_map.hasOwnProperty('md')) {
                    sizeHash.global.map = gon.contact_map.md;
                }
            }
            else{
                if(windowWidth  <= 480){
                    sizeHash.overview.pieChartWidth = 280;
                    sizeHash.overview.pieChartHeight = 280;
                    sizeHash.ethnicity.pieChartWidth = 280;
                    sizeHash.ethnicity.pieChartHeight = 280;
                    sizeHash.overview.pieChartLegend = 'none';
                    sizeHash.testscores.barChartWidth = 270;
                    sizeHash.testscores.barChartHeight = 170;
                    sizeHash.testscores.barChartLegend = 'bottom';
                    sizeHash.testscores.barChartAreaWidth = '75%';
                    if (gon.hasOwnProperty('contact_map') && gon.contact_map.hasOwnProperty('md')) {
                        sizeHash.global.map = gon.contact_map.sm;
                    }
                }
            }
        }
    }
    return sizeHash;
};