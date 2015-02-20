// Basic dependencies. This file is loaded before any other GS js files

Function.prototype.gs_bind = function(obj) {
    var method = this;
    return function() {
        return method.apply(obj, arguments);
    };
};

window.GS = window.GS || {};
window.gon = window.gon || {};
