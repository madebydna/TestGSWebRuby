$(function() {
  if (gon.pagename && gon.pagename.indexOf("GS:State") >= 0) {
      GS.googleMap.addToInitDependencyCallbacks(GS.util.wrapFunction(GS.search.schoolSearchForm.init, this, []));
      GS.search.schoolSearchForm.setupTabs(); // switch by loc by name
  }
});