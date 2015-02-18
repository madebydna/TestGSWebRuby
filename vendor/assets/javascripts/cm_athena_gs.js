function cm_replaceAll(find, replace, str) {
  return str.replace(new RegExp(find, 'g'), replace);
}

var cm_mainCode = function() {
    var cafemomis = '';
    var site = '';
    var domain = window.location.hostname;
    var referrer = document.referrer;
    var language = window.navigator.userLanguage || window.navigator.language;
    
    var img  = document.createElement('img');
    img.src  =  "//pixel.mathtag.com/event/img?mt_id=673196&mt_adid=105595&v1=&v2=&v3=&s1=&s2=&s3=";
    document.getElementsByTagName('head').item(0).appendChild(img);
    site = 'greatschools';

    var random_number = Math.floor((Math.random() * 1000) + 1);
    if (random_number == 1) {
        var img  = document.createElement('img');
        img.src  =  "//secure-us.imrworldwide.com/cgi-bin/m?ci=nlsnapi13512&am=3&ep=1&at=view&rt=banner&st=image&ca=cmp146889&cr=crv569747&pc=plc9195998&r=42";
        document.getElementsByTagName('head').item(0).appendChild(img);
    }

    if (typeof cm_query == "undefined") {
        try {
            var cm_query = document.getElementById("cm_athena").src.split("query=")[1];
            cm_query = cm_replaceAll("=", ":", cm_query);
            cm_array = cm_query.split("&");
            cm_query = '';
            if (cm_array.length > 0) {
                for (var i = 0, len = cm_array.length; i < len; i++) {
                    cm_query += "&s" + (i+1) + "=" + cm_array[i];
                }
            } else {
                cm_query = '&s1=&s2=&s3=';
            }
        }
        catch(err){
            var cm_query = '&s1=&s2=&s3=';
        }
    }
    var img  = document.createElement('img');
    img.src  = "//pixel.mathtag.com/event/img?mt_id=673188&mt_adid=105595&v1=&v2="+site+"&v3="+cafemomis+"&v4="+language+"&v5="+referrer+cm_query;
    document.getElementsByTagName('head').item(0).appendChild(img);
};

try {
    cm_mainCode();
}
catch(err) {

}
