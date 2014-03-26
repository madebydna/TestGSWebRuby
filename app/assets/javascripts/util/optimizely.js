if(window.gon !== undefined){
    if(gon.optimizely_key !== null && gon.optimizely_key !== undefined){
        $.getScript("http://cdn.optimizely.com/js/"+ gon.optimizely_key +".js");
    }
}
window.optimizely = window.optimizely || [];
window.optimizely.push("activateSiteCatalyst");
