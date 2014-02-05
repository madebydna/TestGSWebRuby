var GS = GS || {};
GS.util = GS.util || {};

GS.util.log = function (msg) {
    if (window.console) {
        console.log(msg);
    }
};