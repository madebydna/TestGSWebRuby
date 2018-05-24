export const XS = 0;
export const SM = 1;
export const MD = 2;
export const LG = 3;

export const validSizes = [XS, SM, MD, LG];

export function viewport() {
  let e = window,
    a = 'inner';
  if (!('innerWidth' in window)) {
    a = 'client';
    e = document.documentElement || document.body;
  }
  return { width: e[`${a}Width`], height: e[`${a}Height`] };
}

export function size() {
  const width = viewport().width;
  if (width < 768) {
    return XS;
  } else if (width < 992) {
    return SM;
  } else if (width < 1200) {
    return MD;
  }
  return LG;
}
