export function viewport() {
  var e = window, a = 'inner';
  if (!('innerWidth' in window )) {
    a = 'client';
    e = document.documentElement || document.body;
  }
  return { width : e[ a+'Width' ] , height : e[ a+'Height' ] };
}

export function size() {
  let width = viewport().width;
  if (width < 768) {
    return 'xs';
  } else if (width < 992) {
    return 'sm'
  } else if (width < 1200) {
    return 'md';
  } else {
    return 'lg';
  }
}
