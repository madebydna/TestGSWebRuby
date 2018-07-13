import { gsGeocode } from '../components/autocomplete/search';

export const XS = 0;
export const SM = 1;
export const MD = 2;
export const LG = 3;

export const validSizes = [XS, SM, MD, LG];

// inner box of window scroll area, relative to document
const viewportBox = () => {
  const top =
    typeof window.pageYOffset === 'undefined'
      ? (document.scrollingElement || document.documentElement).scrollTop
      : window.pageYOffset;
  const bottom = top + window.innerHeight;
  const left =
    typeof window.pageXOffset === 'undefined'
      ? (document.scrollingElement || document.documentElement).scrollLeft
      : window.pageXOffset;
  const right = window.innerWidth;
  return {
    top,
    bottom,
    left,
    right,
    height: bottom - top,
    width: right - left
  };
};

// calculate outer box relative to document
const boxInDoc = el => {
  const rect = el.getBoundingClientRect();
  const top = rect.top + viewportBox().top;
  const bottom = top + rect.height;
  const left = rect.left + viewportBox().left;
  const right = left + rect.width;

  return {
    top,
    bottom,
    left,
    right,
    height: top - bottom,
    width: right - left
  };
};

export const distanceTo = (box, otherBox) => ({
  top: box.top - otherBox.top,
  bottom: box.bottom - otherBox.bottom,
  left: box.left - otherBox.left,
  right: box.right - otherBox.right
});

export const intersection = (box, otherBox) => {
  const top = Math.max(box.top, otherBox.top);
  const bottom = Math.min(box.bottom, otherBox.bottom);
  const left = Math.max(box.left, otherBox.left);
  const right = Math.min(box.right, otherBox.right);
  if (top >= bottom && right >= left) {
    return {
      top,
      bottom,
      left,
      right
    };
  }
  return null;
};

const boxEquals = (box, otherBox) =>
  box.top === otherBox.top &&
  box.bottom === otherBox.bottom &&
  box.left === otherBox.left &&
  box.right === otherBox.right;

const boxContains = (box, otherBox) =>
  boxEquals(intersection(box, otherBox), otherBox);

export const isIntersection = (box, otherBox) => !!intersection(box, otherBox);

export const amountElementTopAboveViewport = el =>
  distanceTo(viewportBox(), boxInDoc(el)).top;

export const amountElementBottomBelowViewport = el =>
  -1 * distanceTo(viewportBox(), boxInDoc(el)).bottom;

export const elementInViewport = el =>
  isIntersection(boxInDoc(el), viewportBox());

export const elementEntirelyInViewport = el =>
  boxContains(viewportBox(), boxInDoc(el));

export const maxTopVsViewport = el =>
  Math.max(boxInDoc(el).top, viewportBox().top);

export const minBottomVsViewport = el =>
  Math.min(boxInDoc(el).bottom, viewportBox().bottom);

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
