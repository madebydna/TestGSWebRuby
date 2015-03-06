  (function (i, s, o, g, r, a, m) {
    i['GoogleAnalyticsObject'] = r;
    i[r] = i[r] || function () {
      (i[r].q = i[r].q || []).push(arguments)
    }, i[r].l = 1 * new Date();
    a = s.createElement(o),
      m = s.getElementsByTagName(o)[0];
    a.async = 1;
    a.src = g;
    m.parentNode.insertBefore(a, m)
  })(window, document, 'script', '//www.google-analytics.com/analytics.js', 'ga');

  ga('create', 'UA-54676320-1', 'auto');
  // To test on localhost use the following. However it will be reported on production reports.That is ok since its in pilot phase.
  // Have a follow up ticket to configure it to show up on the reports for deveplment environment in google.
  // ga('create', 'UA-54676320-1', {'cookieDomain': 'none'});
  ga('send', 'pageview');
