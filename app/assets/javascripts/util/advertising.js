var GS = GS || {};
GS.ad = GS.ad || {};
GS.ad.slot = {};

//adobe
GS.ad.AamGpt = {
    strictEncode: function(str){
        return encodeURIComponent(str).replace(/[!'()]/g, escape).replace(/\*/g, "%2A");
    },
    getCookie: function(c_name)
    {
        var i,x,y,c=document.cookie.split(";");
        for (i=0;i<c.length;i++)
        {
            x=c[i].substr(0,c[i].indexOf("="));
            y=c[i].substr(c[i].indexOf("=")+1);
            x=x.replace(/^\s+|\s+$/g,"");
            if (x==c_name)
            {
                return unescape(y);
            }
        }
    },
    getKey: function(c_name){
        var c=this.getCookie(c_name);
        c=this.strictEncode(c);
        if(typeof c != "undefined" && c.match(/\w+%3D/)){
            var cList=c.split("%3D");
            if(typeof cList[0] != "undefined" && cList[0].match(/\w+/))
            {
                return cList[0];
            }
        }
    },
    getValues: function(c_name){
        var c=this.getCookie(c_name);
        c=this.strictEncode(c);
        if(typeof c != "undefined" && c.match(/\w+%3D\w+/)){
            var cList=c.split("%3D");
            if(typeof cList[1] != "undefined" && cList[1].match(/\w+/))
            {
                var vList=cList[1].split("%2C");
                if(typeof vList[0] != "undefined")
                {
                    return vList;
                } else {
                    return null;
                }
            } else {
                return null;
            }
        } else {
            return null;
        }
    }
};



var googletag = googletag || {};
googletag.cmd = googletag.cmd || [];
(function() {
    var gads = document.createElement('script');
    gads.async = true;
    gads.type = 'text/javascript';
    var useSSL = "https:" == document.location.protocol;
    gads.src = (useSSL ? "https:" : "http:") + "//www.googletagservices.com/tag/js/gpt.js";
    var node = document.getElementsByTagName('script')[0];
    node.parentNode.insertBefore(gads, node);
})();


$(function(){
    var dfp_slots = $("body").find(".gs_ad_slot").filter(":visible");
//    var i=0;
    
    if (dfp_slots.length > 0) {
        googletag.cmd.push(function() {
            $(dfp_slots).each(function(){
                GS.ad.slot[$(this).attr('id')] = googletag.defineSlot('/1002894/' + $(this).attr('data-dfp'), JSON.parse($(this).attr('data-ad-size')), $(this).attr('id')).addService(googletag.pubads());
            });

            // add targeting for adobe
            GS.ad.AamCookieName = "gpt_aam";
            if (typeof GS.ad.AamGpt.getCookie(GS.ad.AamCookieName) !== 'undefined') {
                googletag.pubads().setTargeting(GS.ad.AamGpt.getKey(GS.ad.AamCookieName), GS.ad.AamGpt.getValues(GS.ad.AamCookieName));
            }
            if(typeof GS.ad.AamGpt.getCookie("aam_uuid") !== "undefined" ){
                googletag.pubads().setTargeting("aamId", GS.ad.AamGpt.getCookie("aam_uuid"));
            };

            googletag.enableServices();

            $(dfp_slots).each(function(){
                googletag.display($(this).attr('id'));
            });
        });
    }
});

GS.ad.refresh_by_id = function(id){
    googletag.pubads().refresh(GS.ad.slot[id]);
}

// desktop
//<div class="adslot visible-lg visible-md" id="div-gpt-ad-1397603538853-0" data-ad-size="[[300,600],[300,250]]" style="width: 300px; height: 250px;" data-dfp="School_Overview_Snapshot_300x250"></div>

// mobile
//<div class="adslot visible-sm visible-xs" id="div-gpt-ad-1397602726713-0" data-ad-size="[300,250]" style="width: 300px; height: 250px;" data-dfp="School_Overview_Mobile_Snapshot_300x250"></div>